--[=[
	@class WxPane


]=]

local require = require(script.Parent.loader).load(script)

local BaseObject = require("BaseObject")
local Blend = require("Blend")
local FrondAttrs = require("FrondAttrs")
local WxLabel = require("WxLabel")
local FrondConstants = require("FrondConstants")
local WxColors = require("WxColors")

local WxPane = setmetatable({}, BaseObject)
WxPane.ClassName = "WxPane"
WxPane.__index = WxPane

function WxPane.new(obj)
	local self = setmetatable(BaseObject.new(obj), WxPane)

	self._paddingValue = Instance.new("IntValue")
	self._paddingValue.Value = 16
	self._maid:GiveTask(self._paddingValue)

	self._titleLabel = WxLabel.new()
	self._titleLabel:SetText(("Responsive dialogue!"):upper())
	self._titleLabel:SetTextSize(48)
	self._titleLabel:SetWeight(Enum.FontWeight.SemiBold)
	self._maid:GiveTask(self._titleLabel)

	self._footerValue = Instance.new("ObjectValue")
	self._maid:GiveTask(self._footerValue)

	self._bodyValue = Instance.new("ObjectValue")
	self._maid:GiveTask(self._bodyValue)

	self._maid:GiveTask(self:_render():Subscribe(function(gui)
		self.Gui = gui
	end))

	return self
end

function WxPane:SetTitle(title: string)
	self._titleLabel:SetText(title)
end

function WxPane:GetFooterSlot()
	return self._footerValue.Value
end

function WxPane:GetBodySlot()
	return self._bodyValue.Value
end

function WxPane:_render()
	return Blend.New("Frame")({
		BackgroundTransparency = 1,
		[FrondAttrs.FlowDirection] = FrondConstants.DIRECTION_COLUMN,
		[FrondAttrs.AlignItems] = FrondConstants.ALIGN_STRETCH,
		Blend.New("Frame")({
			BackgroundColor3 = WxColors["slate"][800],
			[FrondAttrs.Padding] = self._paddingValue,
			self._titleLabel.Gui,
			Blend.New("UICorner")({
				CornerRadius = UDim.new(0, 8),
			}),
			Blend.New("Frame")({
				Size = UDim2.new(1, 0, 0.5, 0),
				Position = UDim2.fromScale(0, 0.5),
				BackgroundColor3 = WxColors["slate"][800],
				ZIndex = -1,
			}),
		}),
		Blend.New("Frame")({
			BackgroundColor3 = WxColors["slate"][900],
			[FrondAttrs.FlowDirection] = FrondConstants.DIRECTION_COLUMN,
			[FrondAttrs.Padding] = self._paddingValue,
			[FrondAttrs.Gap] = self._paddingValue,
			[Blend.Instance] = self._bodyValue,
		}),
		Blend.New("Frame")({
			BackgroundColor3 = WxColors["slate"][800],
			[FrondAttrs.FlowDirection] = FrondConstants.DIRECTION_ROW,
			[FrondAttrs.Gap] = self._paddingValue,
			[FrondAttrs.Padding] = self._paddingValue,
			[FrondAttrs.AlignItems] = FrondConstants.ALIGN_CENTER,
			[Blend.Instance] = self._footerValue,
			Blend.New("UICorner")({
				CornerRadius = UDim.new(0, 8),
			}),
			Blend.New("Frame")({
				Size = UDim2.new(1, 0, 0.5, 0),
				BackgroundColor3 = WxColors["slate"][800],
				ZIndex = -1,
			}),
		}),
	})
end

return WxPane
