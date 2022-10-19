--[=[
	@class SoundScriptRegistryServiceClient
	@client

	Handles registry of [SoundScript]s. SoundScripts are stored with an associated name, allowing [SoundscapeTrigger]s to reference them via a string attribute.

	Registration is designed to be very flexible. You can register a SoundScript at any time with [SoundScriptRegistryServiceClient:RegisterSoundScript].
	You can also write to an existing key with a new table - and if that soundscape is currently playing, playback will automatically restart with the new sounds.
]=]

local require = require(script.Parent.loader).load(script)

local ObservableMap = require("ObservableMap")
local RxBrioUtils = require("RxBrioUtils")
local SoundScriptConstants = require("SoundScriptConstants")
local Maid = require("Maid")
local Rx = require("Rx")

local SoundScriptRegistryServiceClient = {}

function SoundScriptRegistryServiceClient:Init(serviceBag)
	self._serviceBag = assert(serviceBag, "No serviceBag")

	self._maid = Maid.new()

	-- We need a map as scripts may change, or not be registed instantly.
	-- We may lazily submit scripts as we change maps, locations, etc.
	-- This is the problem with letting users submit a table, it'll turn up any time they please.
	-- Would be so much easier if we had some kind of datamodel JSON instance, or maybe a series of nested folders & ValueBases.
	self._soundScriptMap = ObservableMap.new()
	self._maid:GiveTask(self._soundScriptMap)

	-- Load all of our default scripts.
	for name, soundScript in SoundScriptConstants do
		self:RegisterSoundScript(name, soundScript)
	end
end

--[=[
    Registers a [SoundScript] to be used by [SoundscapeTrigger]s.

    @param name string
    @param soundScript SoundScript
]=]
function SoundScriptRegistryServiceClient:RegisterSoundScript(name: string, soundScript: table)
	-- TODO: More in-depth typechecking of SoundScripts.
	-- See [SoundScriptConstants] for more details on the format.
	assert(typeof(name) == "string", "Bad SoundScript name")
	assert(typeof(soundScript) == "table", "Bad SoundScript table")
	assert(table.isfrozen(soundScript), "SoundScript tables must be frozen as an acknowledgement that they aren't dynamic")

	self._soundScriptMap:Set(name, soundScript)
end

--[=[
    Observes the contents of a [SoundScript] inside the registry given its name.

    @param name string
    @return Observable<Brio<SoundScript?>>
]=]
function SoundScriptRegistryServiceClient:ObserveSoundScriptBrio(name: string)
	return self._soundScriptMap:ObserveValueForKey(name):Pipe({
		Rx.defaultsToNil,
		RxBrioUtils.switchToBrio,
	})
end

function SoundScriptRegistryServiceClient:Destroy()
	self._maid:DoCleaning()
end

return SoundScriptRegistryServiceClient
