"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[878],{28600:e=>{e.exports=JSON.parse('{"functions":[{"name":"makeVisibleSwitch","desc":"Creates a [SwitchBarElement] underneath a [StoryBar], bound to the visibility of a GUI class inherting [BasicPane].\\n\\n```lua\\n\\t-- Create UI.\\n\\tlocal exampleBasicPane = ClassThatInheritsBasicPane.new()\\n\\tmaid:GiveTask(exampleBasicPane)\\n\\t-- Bind UI visiblity to switch.\\n\\tlocal bar = StoryBarUtils.createStoryBar(maid, target)\\n\\tStoryBarPaneUtils.makeVisibleSwitch(bar, exampleBasicPane)\\n```","params":[{"name":"storyBar","desc":"","lua_type":"StoryBar"},{"name":"basicPane","desc":"","lua_type":"BasicPane"},{"name":"name","desc":"","lua_type":"string?"}],"returns":[{"desc":"","lua_type":"SwitchBarElement"}],"function_type":"static","source":{"line":32,"path":"src/storybar/Client/StoryBarPaneUtils.lua"}}],"properties":[],"types":[],"name":"StoryBarPaneUtils","desc":"Utils for glueing story bar elements to Nevermore BasicPanes. State is observed, allowing a switch to both control and respond.\\n\\n![Switch Controlling Basic Pane Visibility Gif](/evenmore/storybar/basicpaneswitch.gif)","source":{"line":8,"path":"src/storybar/Client/StoryBarPaneUtils.lua"}}')}}]);