--[=[
	@class SoundscapeServiceClient
	@client

	Manages selecting and playing soundscapes on the client.
]=]

local require = require(script.Parent.loader).load(script)

local DEFAULT_SOUNDSCAPE_NAME = "default"
local DEFAULT_MASTER_VOLUME = 0.15
local UPDATE_SOUNDSCAPE_HZ = 5

local SoundService = game:GetService("SoundService")

local Maid = require("Maid")
local Rx = require("Rx")
local RxBrioUtils = require("RxBrioUtils")
local SoundscapeBindersClient = require("SoundscapeBindersClient")
local SoundscapeUtils = require("SoundscapeUtils")
local RxValueBaseUtils = require("RxValueBaseUtils")
local SoundScriptRegistryServiceClient = require("SoundScriptRegistryServiceClient")
local FocalPointUtils = require("FocalPointUtils")

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

	self._currentSoundscapeName = Instance.new("StringValue")
	self._currentSoundscapeName.Value = DEFAULT_SOUNDSCAPE_NAME
	self._maid:GiveTask(self._currentSoundscapeName)
end

--[=[
	Begins searching for (and playing) soundscapes. Should be done via [ServiceBag].
]=]
function SoundscapeServiceClient:Start()
	self._soundGroup = Instance.new("SoundGroup")
	self._soundGroup.Name = "Soundscape"
	self._soundGroup.Volume = DEFAULT_MASTER_VOLUME
	self._soundGroup.Archivable = false
	self._soundGroup.Parent = SoundService
	self._maid:GiveTask(self._soundGroup)

	self._maid:GiveTask(Rx.timer(0, 1 / UPDATE_SOUNDSCAPE_HZ)
		:Pipe({
			Rx.switchMap(function()
				return self:ObserveBestSoundscapeNameForPoint(FocalPointUtils.getFocalPoint())
			end),
		})
		:Subscribe(function(soundscapeName: string)
			self._currentSoundscapeName.Value = soundscapeName
		end))

	self._maid:GiveTask(self:ObserveCurrentSoundScriptBrio():Subscribe(function(brio)
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
	@return string
]=]
function SoundscapeServiceClient:ObserveBestSoundscapeNameForPoint(point: Vector3)
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

	-- Observe the name associated with our chosen trigger, or fallback to the default.
	return if soundscapes[1] then soundscapes[1]:ObserveName() else Rx.of(DEFAULT_SOUNDSCAPE_NAME)
end

--[=[
	Observe the name of the currently chosen soundscape.
	This is the same used internally for playing sounds.
	Updates periodically.

	@private
	@return Observable<Brio<string>>
]=]
function SoundscapeServiceClient:ObserveCurrentSoundscapeNameBrio()
	return RxValueBaseUtils.observeValue(self._currentSoundscapeName):Pipe({
		RxBrioUtils.switchToBrio,
	})
end

--[=[
	Observe the [SoundScript] of the currently playing soundscape!

	@private
	@return Observable<Brio<SoundScript>>
]=]
function SoundscapeServiceClient:ObserveCurrentSoundScriptBrio()
	return self:ObserveCurrentSoundscapeNameBrio():Pipe({
		RxBrioUtils.switchMapBrio(function(soundscapeName: string)
			return self._registry:ObserveSoundScriptBrio(soundscapeName)
		end),
	})
end

function SoundscapeServiceClient:_handleSoundScriptBrio(brio)
	-- TODO: Use an ObservableList to push layers, and collect duplicate layers.
	-- This will allow us to have smooth transitions between soundscapes
	-- - i.e. if a soundscape dropped a sound but kept all params the same, we'd only destroy that one layer.

	-- TODO: Fade sounds in/out when SoundScript changes.

	local maid = brio:ToMaid()
	local soundScript = brio:GetValue()

	SoundService.AmbientReverb = soundScript.reverb or Enum.ReverbType.NoReverb

	for i, entry in soundScript.layers or {} do
		local sound = Instance.new("Sound")
		sound.Name = i .. "#" .. entry.id
		sound.Looped = entry.loop
		sound.SoundGroup = self._soundGroup
		sound.SoundId = entry.id
		sound.Archivable = false
		sound.Parent = self._soundGroup
		maid:GiveTask(sound)

		local function playSound()
			sound.PlaybackSpeed = SoundscapeUtils.ev(entry.pitch, 1)
			sound.Volume = SoundscapeUtils.ev(entry.volume, 1)
			sound.TimePosition = SoundscapeUtils.ev(entry.seek, 0)
			sound:Play()
		end

		if entry.delay and not entry.loop then
			-- Play at re-occuring intervals according to the script.
			-- We don't want to re-trigger looping sounds! They'll all play immediately.
			maid:GiveTask(task.defer(function()
				task.wait(SoundscapeUtils.ev(entry.delay))
				playSound()
			end))
		else
			-- Play immediately!
			playSound()
		end
	end
end

function SoundscapeServiceClient:Destroy()
	self._maid:DoCleaning()
end

return SoundscapeServiceClient
