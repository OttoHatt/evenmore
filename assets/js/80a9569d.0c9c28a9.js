"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[382],{83570:e=>{e.exports=JSON.parse('{"functions":[],"properties":[{"name":"default","desc":"No sounds. No reverb.","lua_type":"SoundScript","readonly":true,"source":{"line":37,"path":"src/soundscape/Client/SoundScriptConstants.lua"}},{"name":"city","desc":"Traffic, cars honking, train passing, birds. Echoey reverb like you\'re between buildings.","lua_type":"SoundScript","readonly":true,"source":{"line":45,"path":"src/soundscape/Client/SoundScriptConstants.lua"}},{"name":"park","desc":"Birds, wind, tree movement. Subtle, dead reverb.","lua_type":"SoundScript","readonly":true,"source":{"line":109,"path":"src/soundscape/Client/SoundScriptConstants.lua"}}],"types":[{"name":"SoundScript","desc":"","lua_type":"{ reverb: Enum.ReverbType, layers: {SoundEntry} }","source":{"line":15,"path":"src/soundscape/Client/SoundScriptConstants.lua"}},{"name":"SoundEntry","desc":"","lua_type":"{ id: string, loop: boolean?, volume: SoundValue, pitch: SoundValue, delay: SoundValue }","source":{"line":18,"path":"src/soundscape/Client/SoundScriptConstants.lua"}},{"name":"SoundValue","desc":"This is a low-level property for a soundscript. These are evaluated each delay a sound is played.\\n\\n* A number in -> The same number out\\n* A two-long number array in -> A random value within the range of the two\\n* A \'nil\' in -> a \'nil\' out, falling back to a default value (i.e. volume = 1)","lua_type":"{ number } | number | nil","source":{"line":28,"path":"src/soundscape/Client/SoundScriptConstants.lua"}}],"name":"SoundScriptConstants","desc":"This modules defines the format of SoundScripts, and a few generic templates that you can use in your own games.\\nSoundScripts in this module are automatically loaded; simply put the name of one (i.e. `city`) in a tagged trigger to use it.\\n\\nIf you create a soundscape with this system, consider submitting a PR! This module is most valuable as a portable library of soundscapes.\\n\\nFormat inspired by the [Source Engine soundscape system](https://developer.valvesoftware.com/wiki/Soundscape).","realm":["Client"],"source":{"line":12,"path":"src/soundscape/Client/SoundScriptConstants.lua"}}')}}]);