"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[259],{45976:e=>{e.exports=JSON.parse('{"functions":[{"name":"RegisterSoundScript","desc":"Registers a [SoundScript] to be used by [SoundscapeTrigger]s.","params":[{"name":"name","desc":"Arbitrary, just used as a way to identify this [SoundScript].","lua_type":"string"},{"name":"soundScript","desc":"","lua_type":"SoundScript"}],"returns":[],"function_type":"method","source":{"line":44,"path":"src/soundscape/Client/SoundScriptRegistryServiceClient.lua"}},{"name":"ObserveSoundScriptBrio","desc":"Observe the contents of a [SoundScript] given its name inside the registry.\\nIf not found, the Observable won\'t complete.","params":[{"name":"name","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"Observable<Brio<SoundScript>>"}],"function_type":"method","source":{"line":61,"path":"src/soundscape/Client/SoundScriptRegistryServiceClient.lua"}}],"properties":[],"types":[],"name":"SoundScriptRegistryServiceClient","desc":"Handles registry of [SoundScript]s. SoundScripts are stored with an associated name, allowing [SoundscapeTrigger]s to reference them via a string attribute.\\n\\nRegistration is designed to be very flexible. You can register a SoundScript at any time with [SoundScriptRegistryServiceClient:RegisterSoundScript].\\nYou can also write to an existing key with a new table - and if that soundscape is currently playing, playback will automatically restart with the new sounds.","realm":["Client"],"source":{"line":10,"path":"src/soundscape/Client/SoundScriptRegistryServiceClient.lua"}}')}}]);