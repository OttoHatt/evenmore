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

local WxLabel = setmetatable({}, BaseObject)
WxLabel.ClassName = "WxLabel"
WxLabel.__index = WxLabel

function WxLabel.new(obj)
	local self = setmetatable(BaseObject.new(obj), WxLabel)

	self._textValue = ValueObject.new("", "string")
	self._maid:GiveTask(self._textValue)

	self._weightValue = ValueObject.new(Enum.FontWeight.Regular)
	self._maid:GiveTask(self._weightValue)

	self._textSizeValue = ValueObject.new(32, "number")
	self._maid:GiveTask(self._textSizeValue)

	self._sizeValue = ValueObject.new(Vector3.zero, "Vector3")
	self._maid:GiveTask(self._sizeValue)

	self._colorValue = ValueObject.new(Color3.new(1, 1, 1), "Color3")
	self._maid:GiveTask(self._colorValue)

	self._maxWidth = ValueObject.new(0, "number")
	self._maid:GiveTask(self._maxWidth)

	self._fontIdValue = ValueObject.new(WxConstants.FONT_KANIT)
	self._maid:GiveTask(self._fontIdValue)

	self._transparencyValue = ValueObject.new(0, "number")
	self._maid:GiveTask(self._transparencyValue)

	self._lineHeightValue = ValueObject.new(1, "number")
	self._maid:GiveTask(self._lineHeightValue)

	self._maid:GiveTask(self:_render():Subscribe(function(gui)
		self.Gui = gui
	end))

	-- Assumes label exists immediately!
	-- TODO: Hackily defer update to prevent spam from changing properties at init...!
	self._maid:GiveTask(task.defer(function()
		local params = Instance.new("GetTextBoundsParams")
		self._maid:GiveTask(Blend.mount(params, {
			Size = self._textSizeValue,
			Font = self:_observeFont(),
			Text = self._textValue,
			Width = self._maxWidth,
		}))
		self._maid:GiveTask(params)

		local interSizeValue = ValueObject.new(Vector3.zero, "Vector3")
		self._maid:GiveTask(interSizeValue)

		local function updateDimensions()
			self._maid._updatePromise = TextServiceUtils.promiseTextBounds(params)
			self._maid._updatePromise:Then(function(size: Vector2)
				interSizeValue.Value = Vector3.new(size.X, size.Y)
			end)
		end

		self._maid:GiveTask(params.Changed:Connect(updateDimensions))
		updateDimensions()

		self._maid:GiveTask(
			self._sizeValue:Mount(
				Blend.Computed(interSizeValue, self._lineHeightValue, function(size: Vector3, lineHeight: number)
					return Vector3.new(size.X, size.Y * lineHeight, 0)
				end)
			)
		)
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

function WxLabel:SetFont(font: any)
	self._fontIdValue.Value = font
end

function WxLabel:SetWeight(weight: Enum.FontWeight)
	assert(typeof(weight) ~= "Enum" or weight.EnumType ~= Enum.FontWeight, "Bad weight")
	self._weightValue.Value = weight
end

function WxLabel:SetText(text: string)
	assert(typeof(text) == "string", "Bad text")
	self._textValue.Value = text
end

function WxLabel:SetSize(size: number)
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

function WxLabel:SetTransparency(transparency: number)
	assert(typeof(transparency) == "number", "Bad transparency")
	self._transparencyValue.Value = transparency
end

function WxLabel:SetLineHeight(scale: number)
	assert(typeof(scale) == "number", "Bad scale")
	self._lineHeightValue.Value = scale
end

function WxLabel:_render()
	return Blend.New("TextLabel")({
		BackgroundTransparency = 1,
		Text = self._textValue,
		TextTransparency = self._transparencyValue,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		FontFace = self:_observeFont(),
		TextSize = self._textSizeValue,
		TextColor3 = self._colorValue,
		LineHeight = self._lineHeightValue,
		TextWrapped = Blend.Computed(self._maxWidth, function(width: number)
			return width > 0
		end),
		[FrondAttrs.Size] = self._sizeValue,
		[Blend.Instance] = self._textLabelValue,
	})
end

return WxLabel
