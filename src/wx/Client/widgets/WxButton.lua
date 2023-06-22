--[=[
	@class WxButton

	Widget button.
]=]

local require = require(script.Parent.loader).load(script)

local BaseObject = require("BaseObject")
local Blend = require("Blend")
local FrondAttrs = require("FrondAttrs")
local GoodSignal = require("GoodSignal")
local ValueObject = require("ValueObject")
local WxLabelUtils = require("WxLabelUtils")

local WxButton = setmetatable({}, BaseObject)
WxButton.ClassName = "WxButton"
WxButton.__index = WxButton

function WxButton.new(obj)
	local self = setmetatable(BaseObject.new(obj), WxButton)

	self.Activated = GoodSignal.new()
	self._maid:GiveTask(self.Activated)

	self._label = WxLabelUtils.makeActionLabel()
	self._maid:GiveTask(self._label)

	self._backgroundValue = ValueObject.new(Color3.new(0, 0, 0), "Color3")
	self._maid:GiveTask(self._backgroundValue)

	self._maid:GiveTask(self:_render():Subscribe(function(gui)
		self.Gui = gui
	end))

	return self
end

function WxButton:SetText(text: string)
	self._label:SetText(text)
end

function WxButton:SetBackground(color: Color3)
	self._backgroundValue.Value = color
end

function WxButton:_render()
	return Blend.New("TextButton")({
		Text = "",
		BackgroundColor3 = self._backgroundValue,
		[Blend.OnEvent("Activated")] = function()
			self.Activated:Fire()
		end,
		[FrondAttrs.Padding] = Vector2.new(24, 12),
		self._label.Gui,
		Blend.New("UICorner")({
			CornerRadius = UDim.new(0, 4),
		}),
	})
end

return WxButton
