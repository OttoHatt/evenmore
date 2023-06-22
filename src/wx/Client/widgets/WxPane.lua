--[=[
	@class WxPane


]=]

local require = require(script.Parent.loader).load(script)

local PATTERN_HEADER = "rbxassetid://13823942217"

local BaseObject = require("BaseObject")
local Blend = require("Blend")
local FrondAttrs = require("FrondAttrs")
local FrondConstants = require("FrondConstants")
local WxLabelUtils = require("WxLabelUtils")
local WxNeoColors = require("WxNeoColors")

local WxPane = setmetatable({}, BaseObject)
WxPane.ClassName = "WxPane"
WxPane.__index = WxPane

function WxPane.new(obj)
	local self = setmetatable(BaseObject.new(obj), WxPane)

	self._titleLabel = WxLabelUtils.makeTitleLabel()
	self._titleLabel:SetText(("Responsive dialogue!"):upper())
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
	local BG_HEADER = WxNeoColors["primary"][500]
	local BG_FOOTER = WxNeoColors["nudes"][100]

	local PADDING = 16
	-- local CORNER_RADIUS = 4 + PADDING
	local CORNER_RADIUS = 8

	return Blend.New("Frame")({
		BackgroundTransparency = 1,
		[FrondAttrs.FlowDirection] = FrondConstants.DIRECTION_COLUMN,
		[FrondAttrs.AlignItems] = FrondConstants.ALIGN_STRETCH,
		Blend.New("Frame")({
			BackgroundColor3 = BG_HEADER,
			ClipsDescendants = true,
			[FrondAttrs.Padding] = Vector3.new(PADDING * 2, PADDING, 0),
			Blend.New("UICorner")({
				CornerRadius = UDim.new(0, CORNER_RADIUS),
			}),
			Blend.New("Frame")({
				Size = UDim2.new(1, 0, 0.5, 0),
				Position = UDim2.fromScale(0, 0.5),
				BackgroundColor3 = BG_HEADER,
				ZIndex = -1,
			}),
			Blend.New("ImageLabel")({
				ScaleType = Enum.ScaleType.Tile,
				TileSize = UDim2.new(0, 96, 0, 96),
				Image = PATTERN_HEADER,
				BackgroundTransparency = 1,
				ImageTransparency = 0.8,
				Size = UDim2.new(1, 0, 2, 0),
				Blend.New("UICorner")({
					CornerRadius = UDim.new(0, CORNER_RADIUS),
				}),
			}),
			self._titleLabel.Gui,
		}),
		Blend.New("Frame")({
			BackgroundColor3 = Color3.new(1, 1, 1),
			ZIndex = 2,
			[FrondAttrs.FlowDirection] = FrondConstants.DIRECTION_COLUMN,
			[FrondAttrs.Padding] = PADDING * 2,
			[FrondAttrs.Gap] = PADDING * 2,
			[Blend.Instance] = self._bodyValue,
		}),
		Blend.New("Frame")({
			BackgroundColor3 = BG_FOOTER,
			[FrondAttrs.FlowDirection] = FrondConstants.DIRECTION_ROW,
			[FrondAttrs.Gap] = PADDING,
			[FrondAttrs.Padding] = PADDING,
			[FrondAttrs.AlignItems] = FrondConstants.ALIGN_CENTER,
			[Blend.Instance] = self._footerValue,
			Blend.New("UICorner")({
				CornerRadius = UDim.new(0, CORNER_RADIUS),
			}),
			Blend.New("Frame")({
				Size = UDim2.new(1, 0, 0.5, 0),
				BackgroundColor3 = BG_FOOTER,
				ZIndex = -1,
			}),
		}),
	})
end

return WxPane
