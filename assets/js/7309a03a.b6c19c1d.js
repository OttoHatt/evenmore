"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[294],{24505:e=>{e.exports=JSON.parse('{"functions":[{"name":"Init","desc":"Initializes the soundscape service on the client. Should be done via [ServiceBag].","params":[{"name":"serviceBag","desc":"","lua_type":"ServiceBag"}],"returns":[],"function_type":"method","source":{"line":31,"path":"src/soundscape/Client/SoundscapeServiceClient.lua"}},{"name":"Start","desc":"Begins searching for (and playing) soundscapes. Should be done via [ServiceBag].","params":[],"returns":[],"function_type":"method","source":{"line":47,"path":"src/soundscape/Client/SoundscapeServiceClient.lua"}},{"name":"SetMasterVolume","desc":"Set the master volume of the soundscape system.","params":[{"name":"volume","desc":"","lua_type":"number"}],"returns":[],"function_type":"method","source":{"line":75,"path":"src/soundscape/Client/SoundscapeServiceClient.lua"}},{"name":"ObserveBestSoundscapeNameForPoint","desc":"Given a point, determine the name of the best soundscape to use with a heuristic.","params":[{"name":"point","desc":"","lua_type":"Vector3"}],"returns":[{"desc":"","lua_type":"string"}],"function_type":"method","private":true,"source":{"line":87,"path":"src/soundscape/Client/SoundscapeServiceClient.lua"}},{"name":"ObserveCurrentSoundscapeNameBrio","desc":"Observe the name of the currently chosen soundscape.\\nThis is the same used internally for playing sounds.\\nUpdates periodically.","params":[],"returns":[{"desc":"","lua_type":"Observable<Brio<string>>"}],"function_type":"method","private":true,"source":{"line":120,"path":"src/soundscape/Client/SoundscapeServiceClient.lua"}},{"name":"ObserveCurrentSoundScriptBrio","desc":"Observe the [SoundScript] of the currently playing soundscape!","params":[],"returns":[{"desc":"","lua_type":"Observable<Brio<SoundScript>>"}],"function_type":"method","private":true,"source":{"line":132,"path":"src/soundscape/Client/SoundscapeServiceClient.lua"}}],"properties":[],"types":[],"name":"SoundscapeServiceClient","desc":"Manages selecting and playing soundscapes on the client.","realm":["Client"],"source":{"line":7,"path":"src/soundscape/Client/SoundscapeServiceClient.lua"}}')}}]);