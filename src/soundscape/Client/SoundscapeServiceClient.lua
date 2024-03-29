--[=[
	@class SoundscapeServiceClient
	@client

	Manages selecting and playing soundscapes on the client.
]=]

local require = require(script.Parent.loader).load(script)

local INITIAL_MASTER_VOLUME = 0.15
local UPDATE_SOUNDSCAPE_HZ = 5

local SoundService = game:GetService("SoundService")

local Maid = require("Maid")
local Rx = require("Rx")
local RxBrioUtils = require("RxBrioUtils")
local SoundscapeBindersClient = require("SoundscapeBindersClient")
local SoundScriptUtils = require("SoundScriptUtils")
local SoundScriptRegistryServiceClient = require("SoundScriptRegistryServiceClient")
local FocalPointUtils = require("FocalPointUtils")
local StateStack = require("StateStack")
local Blend = require("Blend")
local ObservableSet = require("ObservableSet")

local SoundscapeServiceClient = {}

--[=[
	Initializes the soundscape service on the client. Should be done via [ServiceBag].
	@param serviceBag ServiceBag
]=]
function SoundscapeServiceClient:Init(serviceBag)
	self._serviceBag = assert(serviceBag, "No serviceBag")

	self._registry = self._serviceBag:GetService(SoundScriptRegistryServiceClient)
	self._binders = self._serviceBag:GetService(SoundscapeBindersClient)

	self._maid = Maid.new()

	-- We need a stack so that we can revert the setting when a SoundScape is dropped.
	-- Grab the initial value from the service, it's probably 'NoReverb' anyways...
	-- TODO: Account for users changing the Reverb setting themselves.
	self._reverbStack = StateStack.new(SoundService.AmbientReverb)
	self._maid:GiveTask(self._reverbStack)

	-- Storage for all loaded soundscapes.
	self._loadedSoundScriptsSet = ObservableSet.new()
	self._maid:GiveTask(self._loadedSoundScriptsSet)
end

--[=[
	Begins searching for (and playing) soundscapes. Should be done via [ServiceBag].
]=]
function SoundscapeServiceClient:Start()
	self._soundGroup = Instance.new("SoundGroup")
	self._soundGroup.Name = "Soundscape"
	self._soundGroup.Volume = INITIAL_MASTER_VOLUME
	self._soundGroup.Archivable = false
	self._soundGroup.Parent = SoundService
	self._maid:GiveTask(self._soundGroup)

	self._maid:GiveTask(self:ObserveBestSoundScriptBrio():Subscribe(function(brio)
		local maid = brio:ToMaid()
		local soundScript = brio:GetValue()

		-- Push ourselves onto the loaded set!
		maid:GiveTask(self._loadedSoundScriptsSet:Add(soundScript))
	end))

	-- Set the reverb!
	self._maid:GiveTask(Blend.mount(SoundService, {
		AmbientReverb = self._reverbStack:Observe(),
	}))

	-- For each SoundScript we load onto the set...
	self._maid:GiveTask(self._loadedSoundScriptsSet:ObserveItemsBrio():Subscribe(function(brio)
		-- Handle loading.
		self:_handleSoundScriptBrio(brio)
	end))
end

--[=[
	Set the master volume of the soundscape system.

	@param volume number
]=]
function SoundscapeServiceClient:SetMasterVolume(volume: number)
	assert(typeof(volume) == "number" and volume >= 0, "Bad volume")
	self._soundGroup.Volume = volume
end

--[=[
	Given a point, determine the name of the best soundscape to use with a heuristic.

	@private
	@param point Vector3
	@return SoundscapeTrigger
]=]
function SoundscapeServiceClient:GetBestSoundscapeTriggerForPoint(point: Vector3)
	assert(typeof(point) == "Vector3", "Bad point")

	-- Get all colliding soundscapes, then sort in volume ascending.
	-- My thinking is that:
	-- > indoor soundscapes take priority over outdoor soundscapes
	-- > outdoor areas will be typically be some giant volumee covering the whole map
	-- TODO: Use a better algorithm for picking the current soundscape!!!!

	local soundscapes = {}

	for _, trigger in self._binders.SoundscapeTrigger:GetAll() do
		if trigger:CheckAABB(point) then
			table.insert(soundscapes, trigger)
		end
	end

	table.sort(soundscapes, function(a, b)
		return a:GetVolume() < b:GetVolume()
	end)

	-- Observe the name associated with our chosen trigger.
	return soundscapes[1]
end

--[=[
	Observe the [SoundScript] of the currently playing soundscape!

	@private
	@return Observable<Brio<SoundScript>>
]=]
function SoundscapeServiceClient:ObserveBestSoundScriptBrio()
	return Rx.interval(1 / UPDATE_SOUNDSCAPE_HZ):Pipe({
		Rx.map(function()
			-- TODO: This returning nil is so incredibly stupid.
			local focalPoint: Vector3? = FocalPointUtils.getFocalPoint()
			if focalPoint then
				return self:GetBestSoundscapeTriggerForPoint(focalPoint)
			else
				return nil
			end
		end),
		Rx.switchMap(function(trigger)
			return if trigger then trigger:ObserveName() else Rx.of(nil)
		end),
		Rx.distinct(),
		RxBrioUtils.switchToBrio(),
		RxBrioUtils.where(function(soundscapeName: string?)
			return soundscapeName ~= nil
		end),
		RxBrioUtils.switchMapBrio(function(soundscapeName: string)
			return self._registry:ObserveSoundScriptBrio(soundscapeName)
		end),
	})
end

function SoundscapeServiceClient:_handleSoundScriptBrio(brio)
	-- TODO: Use an ObservableList to push layers, and collect duplicate layers.
	-- TODO: Do this by duplicating SoundScript layer tables and overriding the equals operator to a deep comparison.
	-- This will allow us to have smooth transitions between soundscapes
	-- - i.e. if a soundscape dropped a sound but kept all params the same, we'd only destroy that one layer.

	-- TODO: Fade sounds in/out when SoundScript changes.

	local maid = brio:ToMaid()
	local soundScript = brio:GetValue()

	-- Recursively load all included SoundScripts.
	-- We avoid duplication / recursion as the set will stop us from loading the same SoundScript twice.
	for _, includedSoundScript in soundScript.includes or {} do
		maid:GiveTask(self._loadedSoundScriptsSet:Add(includedSoundScript))
	end

	-- Push reverb to stack.
	-- We do this after loading all dependants, so that the first SoundScript takes priority over the reverb.
	-- Should probably use FIFO / a queue, but I'm lazy...
	if soundScript.reverb then
		maid:GiveTask(self._reverbStack:PushState(soundScript.reverb))
	end

	-- Load layers.
	for _, layer in soundScript.layers or {} do
		maid:GiveTask(self:_loadLayer(layer))
	end
end

function SoundscapeServiceClient:_loadLayer(layer)
	local maid = Maid.new()

	local sound = Instance.new("Sound")
	sound.Name = layer.id
	sound.Looped = layer.loop
	sound.SoundGroup = self._soundGroup
	sound.SoundId = layer.id
	sound.Archivable = false
	sound.Parent = self._soundGroup
	maid:GiveTask(sound)

	local function playSound()
		sound.PlaybackSpeed = SoundScriptUtils.ev(layer.pitch, 1)
		sound.Volume = SoundScriptUtils.ev(layer.volume, 1)
		sound.TimePosition = SoundScriptUtils.ev(layer.seek, 0)
		sound:Play()
	end

	if layer.delay and not layer.loop then
		-- Play at re-occuring intervals according to the script.
		-- We don't want to re-trigger looping sounds! They'll all play immediately.
		maid:GiveTask(task.defer(function()
			while true do
				task.wait(SoundScriptUtils.ev(layer.delay))
				playSound()
			end
		end))
	else
		-- Play immediately!
		playSound()
	end

	return maid
end

function SoundscapeServiceClient:Destroy()
	self._maid:DoCleaning()
end

return SoundscapeServiceClient
