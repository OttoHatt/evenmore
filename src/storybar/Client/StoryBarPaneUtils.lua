--[=[
	@class StoryBarPaneUtils

	Utils for glueing story bar elements to Nevermore BasicPanes. State is observed, allowing a switch to both control and respond.

	![Switch Controlling Basic Pane Visibility Gif](/evenmore/storybar/basicpaneswitch.gif)
]=]

local require = require(script.Parent.loader).load(script)

local StoryBarUtils = require("StoryBarUtils")

local StoryBarPaneUtils = {}

--[=[
	Creates a [SwitchBarElement] underneath a [StoryBar], bound to the visibility of a GUI class inherting [BasicPane].

	```lua
		-- Create UI.
		local exampleBasicPane = ClassThatInheritsBasicPane.new()
		maid:GiveTask(exampleBasicPane)
		-- Bind UI visiblity to switch.
		local bar = StoryBarUtils.createStoryBar(maid, target)
		StoryBarPaneUtils.makeVisibleSwitch(bar, exampleBasicPane)
	```

	@param storyBar StoryBar
	@param basicPane BasicPane
	@param name string?
	@return SwitchBarElement
]=]
function StoryBarPaneUtils.makeVisibleSwitch(storyBar, basicPane, name)
	local switch = StoryBarUtils.createSwitch(storyBar, name or "Visible", true)
	local maid = storyBar._maid
	maid:GiveTask(switch:Observe():Subscribe(function(switchState)
		basicPane:SetVisible(switchState)
	end))
	maid:GiveTask(basicPane.VisibleChanged:Connect(function(visible)
		switch:SetValue(visible)
	end))
	maid:GiveTask(basicPane)
	return switch
end

return StoryBarPaneUtils