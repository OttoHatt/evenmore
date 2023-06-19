--[=[
	@class WxLabel

	Label object.
]=]

local require = require(script.Parent.loader).load(script)

local BaseObject = require("BaseObject")
local Blend = require("Blend")
local FrondAttrs = require("FrondAttrs")
local TextServiceUtils = require("TextServiceUtils")
local ValueObject = require("ValueObject")
local WxConstants = require("WxConstants")
local WxColors = require("WxColors")

local WxLabel = setmetatable({}, BaseObject)
WxLabel.ClassName = "WxLabel"
WxLabel.__index = WxLabel

function WxLabel.new(obj)
	local self = setmetatable(BaseObject.new(obj), WxLabel)

	self._textValue = Instance.new("StringValue")
	self._textValue.Value = ""
	self._maid:GiveTask(self._textValue)

	self._weightValue = ValueObject.new(Enum.FontWeight.Regular)
	self._maid:GiveTask(self._weightValue)

	self._textSizeValue = Instance.new("NumberValue")
	self._textSizeValue.Value = 32
	self._maid:GiveTask(self._textSizeValue)

	self._sizeValue = Instance.new("Vector3Value")
	self._sizeValue.Value = Vector3.zero
	self._maid:GiveTask(self._sizeValue)

	self._colorValue = Instance.new("Color3Value")
	self._colorValue.Value = WxColors["slate"][50]
	self._maid:GiveTask(self._colorValue)

	self._maxWidth = Instance.new("NumberValue")
	self._maxWidth.Value = 0
	self._maid:GiveTask(self._maxWidth)

	self._fontIdValue = ValueObject.new()
	self._fontIdValue.Value = WxConstants.FONT_KANIT
	self._maid:GiveTask(self._fontIdValue)

	self._maid:GiveTask(self:_render():Subscribe(function(gui)
		self.Gui = gui
	end))

	-- Assumes label exists immediately!
	local params = Instance.new("GetTextBoundsParams")
	self._maid:GiveTask(Blend.mount(params, {
		Size = self._textSizeValue,
		Font = self:_observeFont(),
		Text = self._textValue,
		Width = self._maxWidth,
	}))
	local function updateDimensions()
		self._maid._updatePromise = TextServiceUtils.promiseTextBounds(params)
		self._maid._updatePromise:Then(function(size: Vector2)
			self._sizeValue.Value = Vector3.new(size.X, size.Y)
		end)
	end
	-- TODO: Hackily defer update to prevent spam from changing properties at init...!
	self._maid:GiveTask(task.defer(function()
		self._maid:GiveTask(params.Changed:Connect(updateDimensions))
		updateDimensions()
	end))

	return self
end

function WxLabel:_observeFont()
	return Blend.Computed(self._weightValue, self._fontIdValue, function(weight: Enum.FontWeight, fontId: any?)
		if typeof(fontId) == "string" then
			return Font.new(fontId, weight, Enum.FontStyle.Normal)
		else
			return Font.fromId(fontId, weight, Enum.FontStyle.Normal)
		end
	end)
end

function WxLabel:SetWeight(weight: Enum.FontWeight)
	assert(typeof(weight) ~= "Enum" or weight.EnumType ~= Enum.FontWeight, "Bad weight")
	self._weightValue.Value = weight
end

function WxLabel:SetText(text: string)
	assert(typeof(text) == "string", "Bad text")
	self._textValue.Value = text
end

function WxLabel:SetTextSize(size: number)
	assert(typeof(size) == "number", "Bad size")
	self._textSizeValue.Value = size
end

function WxLabel:SetColor(color: Color3)
	assert(typeof(color) == "Color3", "Bad color")
	self._colorValue.Value = color
end

function WxLabel:SetMaxWidth(width: number)
	assert(typeof(width) == "number", "Bad width")
	self._maxWidth.Value = width
end

function WxLabel:_render()
	return Blend.New("TextLabel")({
		BackgroundTransparency = 1,
		Text = self._textValue,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		FontFace = self:_observeFont(),
		TextSize = self._textSizeValue,
		TextColor3 = self._colorValue,
		TextWrapped = Blend.Computed(self._maxWidth, function(width: number)
			return width > 0
		end),
		[FrondAttrs.Size] = self._sizeValue,
		[Blend.Instance] = self._textLabelValue,
	})
end

return WxLabel
