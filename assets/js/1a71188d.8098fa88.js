"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[613],{48803:e=>{e.exports=JSON.parse('{"functions":[{"name":"createStoryBar","desc":"Create a new [StoryBar].","params":[{"name":"maid","desc":"","lua_type":"Maid"},{"name":"target","desc":"Intended to be a [Hoarcekat](https://github.com/Kampfkarren/hoarcekat) target.","lua_type":"Instance"}],"returns":[{"desc":"","lua_type":"StoryBar"}],"function_type":"static","source":{"line":50,"path":"src/storybar/Client/StoryBarUtils.lua"}},{"name":"createButton","desc":"Create a button attached to a [StoryBar].","params":[{"name":"storyBar","desc":"","lua_type":"StoryBar"},{"name":"name","desc":"","lua_type":"string"},{"name":"callback","desc":"","lua_type":"() -> ()"}],"returns":[{"desc":"","lua_type":"ButtonBarElement"}],"function_type":"static","source":{"line":68,"path":"src/storybar/Client/StoryBarUtils.lua"}},{"name":"createSwitch","desc":"Create a switch attached to a [StoryBar].","params":[{"name":"storyBar","desc":"","lua_type":"StoryBar"},{"name":"name","desc":"","lua_type":"string"},{"name":"default","desc":"","lua_type":"boolean"},{"name":"callback","desc":"","lua_type":"(value: boolean) -> ()"}],"returns":[{"desc":"","lua_type":"SwitchBarElement"}],"function_type":"static","source":{"line":90,"path":"src/storybar/Client/StoryBarUtils.lua"}},{"name":"createSlider","desc":"Create a slider attached to a [StoryBar].","params":[{"name":"storyBar","desc":"","lua_type":"StoryBar"},{"name":"name","desc":"","lua_type":"string"},{"name":"default","desc":"","lua_type":"number"},{"name":"callback","desc":"","lua_type":"(value: number) -> ()"}],"returns":[{"desc":"","lua_type":"SliderBarElement"}],"function_type":"static","source":{"line":113,"path":"src/storybar/Client/StoryBarUtils.lua"}},{"name":"createRangedSlider","desc":"Create a slider within a range attached to a [StoryBar].","params":[{"name":"storyBar","desc":"","lua_type":"StoryBar"},{"name":"name","desc":"","lua_type":"string"},{"name":"lower","desc":"","lua_type":"number"},{"name":"upper","desc":"","lua_type":"number"},{"name":"mappedDefault","desc":"The default value, between lower and upper (inclusive).","lua_type":"number"},{"name":"callback","desc":"","lua_type":"(value: number) -> ()"}],"returns":[{"desc":"","lua_type":"SliderBarElement"}],"function_type":"static","source":{"line":134,"path":"src/storybar/Client/StoryBarUtils.lua"}}],"properties":[],"types":[],"name":"StoryBarUtils","desc":"Utils for creating story bar, then attaching elements to it.\\n\\n```lua\\n-- Example with a Hoarcekat story.\\n\\nlocal Maid = require(\\"Maid\\")\\nlocal StoryBarUtils = require(\\"StoryBarUtils\\")\\n\\nreturn function(target)\\n\\tlocal maid = Maid.new()\\n\\n\\tlocal bar = StoryBarUtils.createStoryBar(maid, target)\\n\\tStoryBarUtils.createButton(bar, \\"Click button\\", function()\\n\\t\\tprint(\\"Button: Clicked!\\")\\n\\tend)\\n\\tStoryBarUtils.createSwitch(bar, \\"Toggle switch\\", false, function(value: boolean)\\n\\t\\tprint(\\"Switch:\\", value)\\n\\tend)\\n\\tStoryBarUtils.createSlider(bar, \\"Linear slider\\", 0.5, function(value)\\n\\t\\tprint(\\"Value:\\", value)\\n\\tend)\\n\\n\\treturn function()\\n\\t\\tmaid:DoCleaning()\\n\\tend\\nend\\n```","source":{"line":32,"path":"src/storybar/Client/StoryBarUtils.lua"}}')}}]);