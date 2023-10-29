--[=[
	@class WxBox

	Simple border box.
]=]

local require = require(script.Parent.loader).load(script)

local BaseObject = require("BaseObject")
local Blend = require("Blend")
local FrondAttrs = require("FrondAttrs")
local FrondConstants = require("FrondConstants")
local WxNeoColors = require("WxNeoColors")

local WxBox = setmetatable({}, BaseObject)
WxBox.ClassName = "WxBox"
WxBox.__index = WxBox

function WxBox.new(obj)
	local self = setmetatable(BaseObject.new(obj), WxBox)

	self._innerValue = Instance.new("ObjectValue")
	self._maid:GiveTask(self._innerValue)

	return self
end

function WxBox:GetInnerSlot(): GuiBase2d
	return self._innerValue.Value
end

function WxBox:_render()
	local FIXED_HEIGHT = 24 + 8

	return Blend.New("Frame")({
		BackgroundColor3 = WxNeoColors.nudes[900],
		BackgroundTransparency = 1 - 0.95,
		[FrondAttrs.Height] = FIXED_HEIGHT,
		[FrondAttrs.Padding] = 2,
		Blend.New("Frame")({
			BackgroundColor3 = Color3.new(1, 1, 1),
			[FrondAttrs.WidthP] = 1,
			[FrondAttrs.HeightP] = 1,
			[Blend.Instance] = self._innerValue,
			[FrondAttrs.FlowDirection] = FrondConstants.DIRECTION_ROW,
			[FrondAttrs.AlignItems] = FrondConstants.ALIGN_CENTER,
			[FrondAttrs.JustifyContent] = FrondConstants.JUSTIFY_CENTER,
		}),
	})
end

return WxBox
