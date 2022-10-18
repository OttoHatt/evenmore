--[=[
	@class StoryBar

	Cute little bar for use with [Hoarcekat](https://github.com/Kampfkarren/hoarcekat) stories.
	To create as little boilerplate as possible in your stories, it's reccomended that you use [StoryBarUtils] to construct the bar and its child elements.

	![Story Bar Gif](/evenmore/storybar/bar.gif)
]=]

-- TODO: Collapsible UI, using ico 'rbxasset://textures/ui/InspectMenu/ico_inspect@2x.png'.

local require = require(script.Parent.loader).load(script)

local EvenmoreColorTheming = require("EvenmoreColorTheming")
local BaseObject = require("BaseObject")
local ObservableList = require("ObservableList")
local Blend = require("Blend")
local RxBrioUtils = require("RxBrioUtils")

local StoryBar = setmetatable({}, BaseObject)
StoryBar.ClassName = "StoryBar"
StoryBar.__index = StoryBar

--[=[
	Gui object which can be reparented or whatever, typically underneath a Horacekat target.
	@prop Gui Instance?
	@readonly
	@within StoryBar
]=]

--[=[
	Constructs a new StoryBar. You likely don't want to do this directly, see [StoryBarUtils].
	@param serviceBag ServiceBag
	@return StoryBar
]=]
function StoryBar.new(serviceBag)
	local self = setmetatable(BaseObject.new(), StoryBar)

	self._serviceBag = assert(serviceBag, "No serviceBag")
	self._colorTheming = serviceBag:GetService(EvenmoreColorTheming)

	self._elements = ObservableList.new()
	self._maid:GiveTask(self._elements)

	self._maid:GiveTask(self:_render():Subscribe(function(gui)
		self.Gui = gui
	end))

	return self
end

--[=[
	Push a constructed [BaseBarElement] onto the StoryBar.
	@param element BaseBarElement.
	@return () -> () -- Cleanup task, call to remove from the bar.
]=]
function StoryBar:PushElement(element)
	return self._elements:Add(element)
end

function StoryBar:_render()
	return Blend.New("Frame")({
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ZIndex = -1,
		[Blend.Children] = {
			Blend.New("UIPadding")({
				PaddingLeft = UDim.new(0, 4),
				PaddingRight = UDim.new(0, 4),
				PaddingBottom = UDim.new(0, 4),
				PaddingTop = UDim.new(0, 4),
			}),
			Blend.New("UIListLayout")({
				Padding = UDim.new(0, 4),
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Top,
			}),
			self._elements:ObserveItemsBrio():Pipe({
				RxBrioUtils.map(function(class)
					return class.Gui
				end)
			})
		},
	})
end

return StoryBar
