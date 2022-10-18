--[=[
	@class StoryBarUtils

	Utils for creating story bar, then attaching elements to it.

	```lua
	-- Example with a Hoarcekat story.

	local Maid = require("Maid")
	local StoryBarUtils = require("StoryBarUtils")

	return function(target)
		local maid = Maid.new()

		local bar = StoryBarUtils.createStoryBar(maid, target)
		StoryBarUtils.createButton(bar, "Click button", function()
			print("Button: Clicked!")
		end)
		StoryBarUtils.createSwitch(bar, "Toggle switch", false, function(value: boolean)
			print("Switch:", value)
		end)
		StoryBarUtils.createSlider(bar, "Linear slider", 0.5, function(value)
			print("Value:", value)
		end)

		return function()
			maid:DoCleaning()
		end
	end
	```
]=]

local require = require(script.Parent.loader).load(script)

local StoryBar = require("StoryBar")
local ButtonBarElement = require("ButtonBarElement")
local SwitchBarElement = require("SwitchBarElement")
local SliderBarElement = require("SliderBarElement")
local Math = require("Math")
local ServiceBag = require("ServiceBag")

local StoryBarUtils = {}

--[=[
	Create a new [StoryBar].
	@param maid Maid
	@param target Instance -- Intended to be a [Hoarcekat](https://github.com/Kampfkarren/hoarcekat) target.
	@return StoryBar
]=]
function StoryBarUtils.createStoryBar(maid, target)
	local serviceBag = ServiceBag.new()
	maid:GiveTask(serviceBag)

	local storyBar = StoryBar.new(serviceBag)
	storyBar.Gui.Parent = target
	maid:GiveTask(storyBar)

	return storyBar
end

--[=[
	Create a button attached to a [StoryBar].
	@param storyBar StoryBar
	@param name string
	@param callback () -> ()
	@return ButtonBarElement
]=]
function StoryBarUtils.createButton(storyBar, name: string, callback)
	local button = ButtonBarElement.new(storyBar._serviceBag)

	button:SetLabel(name)
	if callback then
		storyBar._maid:GiveTask(button.Pressed:Connect(callback))
	end

	storyBar._maid:GiveTask(button)
	storyBar._maid:GiveTask(storyBar:PushElement(button))

	return button
end

--[=[
	Create a switch attached to a [StoryBar].
	@param storyBar StoryBar
	@param name string
	@param default boolean
	@param callback (value: boolean) -> ()
	@return SwitchBarElement
]=]
function StoryBarUtils.createSwitch(storyBar, name: string, default: boolean, callback: (boolean) -> ())
	local switch = SwitchBarElement.new(storyBar._serviceBag)

	switch:SetLabel(name)
	switch:SetValue(default)
	if callback then
		storyBar._maid:GiveTask(switch:Observe():Subscribe(callback))
	end

	storyBar._maid:GiveTask(switch)
	storyBar._maid:GiveTask(storyBar:PushElement(switch))

	return switch
end

--[=[
	Create a slider attached to a [StoryBar].
	@param storyBar StoryBar
	@param name string
	@param default number
	@param callback (value: number) -> ()
	@return SliderBarElement
]=]
function StoryBarUtils.createSlider(storyBar, name, default: number, callback)
	local slider = SliderBarElement.new(storyBar._serviceBag, default)
	slider:SetLabel(name)
	if callback then
		storyBar._maid:GiveTask(slider:Observe():Subscribe(callback))
	end
	storyBar._maid:GiveTask(slider)
	storyBar._maid:GiveTask(storyBar:PushElement(slider))
	return slider
end

--[=[
	Create a slider within a range attached to a [StoryBar].
	@param storyBar StoryBar
	@param name string
	@param lower number
	@param upper number
	@param mappedDefault number -- The default value, between lower and upper (inclusive).
	@param callback (value: number) -> ()
	@return SliderBarElement
]=]
function StoryBarUtils.createRangedSlider(storyBar, name, lower: number, upper: number, mappedDefault: number, callback)
	local defaultValue = Math.map(mappedDefault, lower, upper, 0, 1)
	return StoryBarUtils.createSlider(storyBar, name, defaultValue, function(fac)
		-- Fac in zero to one range.
		callback(Math.map(fac, 0, 1, lower, upper))
	end)
end

return StoryBarUtils
