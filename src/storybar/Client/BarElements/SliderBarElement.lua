--[=[
	@class SliderBarElement
	@private
	@client

	Linear value slider that slots into a [StoryBar].
	You won't want to create this directly; see [StoryBarUtils].

	Sliders are always within the [0-1] range. For a custom range, see [StoryBarUtils.createRangedSlider].

	![Slider Gif](/evenmore/storybar/slider.gif)

]=]

local require = require(script.Parent.loader).load(script)

local BaseBarElement = require("BaseBarElement")
local BaseBarElementUtils = require("BaseBarElementUtils")
local Blend = require("Blend")
local SliderModel = require("SliderModel")
local TextServiceUtils = require("TextServiceUtils")

local SwitchBarElement = setmetatable({}, BaseBarElement)
SwitchBarElement.ClassName = "SwitchBarElement"
SwitchBarElement.__index = SwitchBarElement

function SwitchBarElement.new(serviceBag, initialValue: number)
	local self = setmetatable(BaseBarElement.new(serviceBag), SwitchBarElement)

	self._labelText = Instance.new("StringValue")
	self._labelText.Value = "Slider"
	self._maid:GiveTask(self._labelText)

	self._label = Instance.new("ObjectValue")
	self._maid:GiveTask(self._label)

	self._slider = Instance.new("ObjectValue")
	self._maid:GiveTask(self._slider)

	self._sliderModel = SliderModel.new()
	self._sliderModel:SetValue(initialValue or 0)
	self._maid:GiveTask(self._sliderModel)

	self._maid:GiveTask(self:_render(self.Gui))

	self:_updateLayout()
	self._maid:GiveTask(self.Gui.AncestryChanged:Connect(function()
		self:_updateLayout()
	end))

	return self
end

--[=[
	Observe the slider's value.
	@within SliderBarElement
	@return Observable<number>
]=]
function SwitchBarElement:Observe()
	return self._sliderModel:ObserveValue()
end

--[=[
	Set the slider's current value.
	@private
	@within SliderBarElement
	@return number
]=]
function SwitchBarElement:SetValue(value: number)
	self._sliderModel:SetValue(value)
end

--[=[
	Get the slider's current value.
	@within SliderBarElement
	@return number
]=]
function SwitchBarElement:GetValue()
	return self._sliderModel:GetValue()
end

--[=[
	Set the label text.
	@within SliderBarElement
	@param text string
]=]
function SwitchBarElement:SetLabel(text: string)
	self._labelText.Value = text
end

function SwitchBarElement:_updateLayout()
	local paddingWidth = self:GetPadding()

	local label = self._label.Value
	label.Position = UDim2.new(0, 0, 0.5, 0)
	local textSize = TextServiceUtils.getSizeForLabel(label, label.Text)

	local SLIDER_WIDTH = 128
	local slider = self._slider.Value
	slider.Size = UDim2.new(0, SLIDER_WIDTH, 1, 0)
	slider.Position = UDim2.new(0, textSize.X + 4 + 4, 0, 0)

	self:GetSizeValue().Value = Vector3.new(SLIDER_WIDTH + 8 + 4 + paddingWidth * 2 + textSize.X, self._height, 0)
end

function SwitchBarElement:_render(gui: Instance)
	return Blend.mount(gui, {
		Blend.New("TextButton")({
			Active = true,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			[Blend.Instance] = function(instance: Instance)
				self._sliderModel:SetCatchElement(instance)
			end,
			self:RenderPadding(),
			Blend.New("TextLabel")({
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Font = Enum.Font.FredokaOne,
				FontSize = Enum.FontSize.Size18,
				Position = UDim2.new(0, 0, 0.5, 0),
				Size = UDim2.new(1, 0, 1, 0),
				Text = self._labelText,
				TextColor3 = self._colorTheming:ObserveColor("Glyph"),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
				[Blend.Instance] = self._label,
			}),
			Blend.New("Frame")({
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				[Blend.Instance] = function(instance: Instance)
					self._sliderModel:SetReferenceElement(instance)
					self._slider.Value = instance
				end,

				Blend.New("Frame")({
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(0, 0, 0.5, 0),
					Size = UDim2.new(1, 0, 0, 2),
					BackgroundColor3 = self._colorTheming:ObserveColor("Glyph"),
				}),
				Blend.New("Frame")({
					AnchorPoint = Vector2.new(0.5, 0.5),
					Size = UDim2.new(0, 12, 0, 12),
					BackgroundColor3 = BaseBarElementUtils.observePrimaryColor(
						self._colorTheming,
						self._sliderModel:ObserveInputActive()
					),
					Position = Blend.Spring(
						Blend.Computed(self:Observe(), function(value)
							return UDim2.new(value, 0, 0.5, 0)
						end),
						150
					),
					Blend.New("UICorner")({
						CornerRadius = UDim.new(0, 999),
					}),
				}),
			}),
		}),
	})
end

return SwitchBarElement
