--[=[
	@class WxButton

	Widget button.
]=]

local require = require(script.Parent.loader).load(script)

local BaseObject = require("BaseObject")
local WxLabel = require("WxLabel")
local Blend = require("Blend")
local FrondAttrs = require("FrondAttrs")
local ValueObject = require("ValueObject")
local WxBackground = require("WxBackground")
local GoodSignal = require("GoodSignal")

local WxButton = setmetatable({}, BaseObject)
WxButton.ClassName = "WxButton"
WxButton.__index = WxButton

function WxButton.new(obj)
	local self = setmetatable(BaseObject.new(obj), WxButton)

	self.Activated = GoodSignal.new()
	self._maid:GiveTask(self.Activated)

	self._label = WxLabel.new()
	self._label:SetTextSize(24)
	self._label:SetWeight(Enum.FontWeight.SemiBold)
	self._maid:GiveTask(self._label)

	self._backgroundValue = ValueObject.new()
	self._maid:GiveTask(self._backgroundValue)

	self._maid:GiveTask(self:_render():Subscribe(function(gui)
		self.Gui = gui
	end))

	return self
end

function WxButton:SetText(text: string)
	self._label:SetText(text)
end

function WxButton:SetBackground(...)
	self._backgroundValue.Value = {...}
end

function WxButton:_render()
	return Blend.New("TextButton")({
		Text = "",
		[FrondAttrs.Padding] = Vector2.new(24, 12),
		[Blend.OnEvent("Activated")] = function()
			self.Activated:Fire()
		end,
		[WxBackground.Polymorphic] = self._backgroundValue,
		[Blend.Children] = {
			self._label.Gui,
			Blend.New("UICorner")({
				CornerRadius = UDim.new(0, 4),
			}),
		},
	})
end

return WxButton
