--[=[
	@class WxToggle

	Toggleable switch element.
]=]

local require = require(script.Parent.loader).load(script)

local IMAGE_X = "rbxassetid://13794478132"
local IMAGE_CHECK = "rbxassetid://13818721938"

local BaseObject = require("BaseObject")
local ValueObject = require("ValueObject")
local Blend = require("Blend")
local FrondAttrs = require("FrondAttrs")
local WxColors = require("WxColors")
local WxBackground = require("WxBackground")
local SpringObject = require("SpringObject")
local Rx = require("Rx")
local FrondConstants = require("FrondConstants")
local WxLabel = require("WxLabel")

local GRADIENT_UNCHECKED = table.freeze({ WxColors["rose"][500], WxColors["red"][600] })
local GRADIENT_CHECKED = table.freeze({ WxColors["emerald"][500], WxColors["teal"][600] })

local WxToggle = setmetatable({}, BaseObject)
WxToggle.ClassName = "WxToggle"
WxToggle.__index = WxToggle

function WxToggle.new(obj)
	local self = setmetatable(BaseObject.new(obj), WxToggle)

	self._stateValue = ValueObject.new(false, "boolean")
	self._maid:GiveTask(self._stateValue)

	-- Keep in sync with button class?
	self._label = WxLabel.new()
	self._label:SetTextSize(24)
	self._label:SetWeight(Enum.FontWeight.SemiBold)
	self._label:SetText("Toggle!")
	self._label:SetColor(WxColors["slate"][300])
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
	local CORNER_RADIUS = 4
	local PADDING_RADIUS = 4
	local FIXED_HEIGHT = 24 * 1.5

	local knockSpring = SpringObject.new(1, 45, 0.9)
	self._maid:GiveTask(self._stateValue.Changed:Connect(function()
		knockSpring:Impulse(100)
	end))
	self._maid:GiveTask(knockSpring)

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
			[FrondAttrs.Size] = FIXED_HEIGHT,
			[FrondAttrs.Padding] = PADDING_RADIUS,
			[WxBackground.Polymorphic] = { WxColors["slate"][600], WxColors["slate"][700] },
			Blend.New("UICorner")({
				CornerRadius = UDim.new(0, CORNER_RADIUS),
			}),
			Blend.New("Frame")({
				[FrondAttrs.WidthP] = 1,
				[FrondAttrs.HeightP] = 1,
				BackgroundColor3 = WxColors["slate"][700],
				[FrondAttrs.Padding] = 4,
				Blend.New("UICorner")({
					CornerRadius = UDim.new(0, CORNER_RADIUS - PADDING_RADIUS),
				}),
				Blend.New("ImageLabel")({
					[FrondAttrs.WidthP] = 1,
					[FrondAttrs.HeightP] = 1,
					[FrondAttrs.Transform] = knockSpring:ObserveRenderStepped():Pipe({
						Rx.map(function(value: number)
							return math.round(value)
						end),
						Rx.map(function(value: number)
							return Vector3.new(0, value, 0)
						end),
					}),
					[WxBackground.Polymorphic] = Blend.Computed(self._stateValue, function(checked: boolean)
						return if checked then GRADIENT_CHECKED else GRADIENT_UNCHECKED
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
