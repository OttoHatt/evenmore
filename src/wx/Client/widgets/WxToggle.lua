--[=[
	@class WxToggle

	Toggleable switch element.
]=]

local require = require(script.Parent.loader).load(script)

local IMAGE_X = "rbxassetid://13794478132"
local IMAGE_CHECK = "rbxassetid://13818721938"

local BaseObject = require("BaseObject")
local Blend = require("Blend")
local FrondAttrs = require("FrondAttrs")
local FrondConstants = require("FrondConstants")
local ValueObject = require("ValueObject")
local WxLabelUtils = require("WxLabelUtils")
local WxNeoColors = require("WxNeoColors")
local WxTransparencies = require("WxTransparencies")

local WxToggle = setmetatable({}, BaseObject)
WxToggle.ClassName = "WxToggle"
WxToggle.__index = WxToggle

function WxToggle.new(obj)
	local self = setmetatable(BaseObject.new(obj), WxToggle)

	self._stateValue = ValueObject.new(false, "boolean")
	self._maid:GiveTask(self._stateValue)

	-- Keep in sync with button class?
	self._label = WxLabelUtils.makeActionLabel()
	self._label:SetSize(24)
	self._label:SetWeight(Enum.FontWeight.Medium)
	self._label:SetText("Toggle!")
	self._label:SetTransparency(0.2)
	self._label:SetColor(Color3.new(0, 0, 0))
	self._maid:GiveTask(self._label)

	self._maid:GiveTask(self:_render():Subscribe(function(gui)
		self.Gui = gui
	end))

	return self
end

function WxToggle:SetText(text: string)
	self._label:SetText(text)
end

function WxToggle:ObserveState()
	return self._stateValue:Observe()
end

function WxToggle:_render()
	local FIXED_HEIGHT = 40

	return Blend.New("TextButton")({
		Text = "",
		BackgroundTransparency = 1,
		[Blend.OnEvent("Activated")] = function()
			self._stateValue.Value = not self._stateValue.Value
		end,
		[FrondAttrs.Height] = FIXED_HEIGHT,
		[FrondAttrs.FlowDirection] = FrondConstants.DIRECTION_ROW,
		[FrondAttrs.AlignItems] = FrondConstants.ALIGN_CENTER,
		[FrondAttrs.Gap] = 16,
		Blend.New("Frame")({
			BackgroundColor3 = WxNeoColors.nudes[900],
			BackgroundTransparency = 1 - 0.95,
			[FrondAttrs.Size] = FIXED_HEIGHT,
			[FrondAttrs.Padding] = 2,
			Blend.New("Frame")({
				[FrondAttrs.WidthP] = 1,
				[FrondAttrs.HeightP] = 1,
				BackgroundColor3 = Color3.new(1, 1, 1),
				[FrondAttrs.Padding] = 4,
				Blend.New("ImageLabel")({
					[FrondAttrs.WidthP] = 1,
					[FrondAttrs.HeightP] = 1,
					ImageColor3 = Blend.Computed(self._stateValue, function(checked: boolean)
						-- return if checked then WxNeoColors.subs[6] else WxNeoColors.subs[3]
						return if checked then WxNeoColors.success[400] else WxNeoColors.danger[400]
					end),
					BackgroundTransparency = 1,
					Image = Blend.Computed(self._stateValue, function(checked: boolean)
						return if checked then IMAGE_CHECK else IMAGE_X
					end),
				}),
			}),
		}),
		self._label.Gui,
	})
end

return WxToggle
