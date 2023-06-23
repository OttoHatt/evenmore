--[=[
	@class WxSlider

	Toggleable switch element.
]=]

local require = require(script.Parent.loader).load(script)

local BaseObject = require("BaseObject")
local Blend = require("Blend")
local FrondAttrs = require("FrondAttrs")
local FrondConstants = require("FrondConstants")
local WxLabelUtils = require("WxLabelUtils")
local WxNeoColors = require("WxNeoColors")
local SliderModel = require("SliderModel")

local WxSlider = setmetatable({}, BaseObject)
WxSlider.ClassName = "WxSlider"
WxSlider.__index = WxSlider

function WxSlider.new(obj)
	local self = setmetatable(BaseObject.new(obj), WxSlider)

	self._label = WxLabelUtils.makeBodyLabel()
	self._label:SetLineHeight(1)
	self._label:SetText("Slider!")
	self._maid:GiveTask(self._label)

	self._sliderModel = SliderModel.new()
	self._maid:GiveTask(self._sliderModel)

	self._maid:GiveTask(self:_render():Subscribe(function(gui)
		self.Gui = gui
	end))

	return self
end

function WxSlider:SetText(text: string)
	self._label:SetText(text)
end

function WxSlider:ObserveValue()
	return self._sliderModel:ObserveValue()
end

function WxSlider:SetValue(value: number)
	self._sliderModel:SetValue(value)
end

function WxSlider:_render()
	local FIXED_WIDTH = 256
	local FIXED_HEIGHT = 24 + 8

	local observeSmoothedValue = Blend.Spring(self:ObserveValue(), 100, 1)

	return Blend.New("TextButton")({
		Text = "",
		BackgroundTransparency = 1,
		[Blend.Instance] = function(instance: Instance)
			self._sliderModel:SetCatchElement(instance)
		end,
		[FrondAttrs.Height] = FIXED_HEIGHT,
		[FrondAttrs.FlowDirection] = FrondConstants.DIRECTION_ROW,
		[FrondAttrs.AlignItems] = FrondConstants.ALIGN_CENTER,
		[FrondAttrs.Gap] = 12,
		Blend.New("Frame")({
			BackgroundColor3 = WxNeoColors.nudes[900],
			BackgroundTransparency = 1 - 0.95,
			[FrondAttrs.Width] = FIXED_WIDTH,
			[FrondAttrs.HeightP] = 1,
			[FrondAttrs.Padding] = 2,
			Blend.New("Frame")({
				BackgroundColor3 = Color3.new(1, 1, 1),
				[FrondAttrs.WidthP] = 1,
				[FrondAttrs.HeightP] = 1,
				[Blend.Instance] = function(instance: Instance)
					self._sliderModel:SetReferenceElement(instance)
				end,
				Blend.New("Frame")({
					BackgroundColor3 = WxNeoColors.primary[500],
					Size = Blend.Computed(observeSmoothedValue, function(value: number)
						return UDim2.fromScale(value, 1)
					end),
				}),
			}),
		}),
		self._label.Gui,
	})
end

return WxSlider
