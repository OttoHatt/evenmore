--[=[
	@class SliderBarElement
	@private

	Linear value slider that slots into a [StoryBar].
	You won't want to create this directly; see [StoryBarUtils].

	Sliders are always within the [0-1] range. For a custom range, see [StoryBarUtils.createRangedSlider].

	![Slider Gif](/evenmore/storybar/slider.gif)

]=]

local require = require(script.Parent.loader).load(script)

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local BaseBarElement = require("BaseBarElement")
local Blend = require("Blend")
local RxValueBaseUtils = require("RxValueBaseUtils")
local TextServiceUtils = require("TextServiceUtils")
local RxInstanceUtils = require("RxInstanceUtils")

local SwitchBarElement = setmetatable({}, BaseBarElement)
SwitchBarElement.ClassName = "SwitchBarElement"
SwitchBarElement.__index = SwitchBarElement

function SwitchBarElement.new(serviceBag, initialValue: number)
	local self = setmetatable(BaseBarElement.new(serviceBag), SwitchBarElement)

	self._label = Instance.new("StringValue")
	self._label.Value = "Slider"
	self._maid:GiveTask(self._label)

	self._value = Instance.new("NumberValue")
	self._value.Value = initialValue or 0
	self._maid:GiveTask(self._value)

	self._slider = Instance.new("ObjectValue")
	self._maid:GiveTask(self._slider)

	self._label = Instance.new("ObjectValue")
	self._maid:GiveTask(self._label)

	self._acceptingInput = Instance.new("BoolValue")
	self._maid:GiveTask(self._acceptingInput)

	self._maid:GiveTask(self:_render(self.Gui))

	self._maid:GiveTask(RxInstanceUtils.observeFirstAncestorBrio(self.Gui, "LayerCollector"):Subscribe(function(brio)
		local collector: Instance = brio:GetValue()
		local maid = brio:ToMaid()
		if collector:IsA("PluginGui") then
			self:_update(collector:GetRelativeMousePosition())
			maid:GiveTask(RunService.RenderStepped:Connect(function()
				self:_update(collector:GetRelativeMousePosition())
			end))
		elseif collector:IsA("ScreenGui") then
			self:_update(UserInputService:GetMouseLocation())
			maid:GiveTask(UserInputService.InputChanged:Connect(function(inputObject: InputObject)
				if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
					self:_update(UserInputService:GetMouseLocation())
				end
			end))
		end
	end))

	self:_updateLayout()
	self._maid:GiveTask(self.Gui.AncestryChanged:Connect(function()
		self:_updateLayout()
	end))

	return self
end

function SwitchBarElement:_updateMovement(raw: Vector2 & Vector3)
	if self._acceptingInput.Value then
		local pos = Vector2.new(raw.X, raw.Y)
		local slider = self._slider.Value
		local off = pos - slider.AbsolutePosition
		local fac = math.clamp(off.X / slider.AbsoluteSize.X, 0, 1)
		self:SetValue(fac)
	end
end

--[=[
	Observe the slider's value.
	@within SliderBarElement
	@return Observable<number>
]=]
function SwitchBarElement:Observe()
	return RxValueBaseUtils.observeValue(self._value)
end

--[=[
	Set the slider's current value.
	@private
	@within SliderBarElement
	@return number
]=]
function SwitchBarElement:SetValue(value: number)
	self._value.Value = value
end

--[=[
	Get the slider's current value.
	@within SliderBarElement
	@return number
]=]
function SwitchBarElement:GetValue()
	return self._value.Value
end

--[=[
	Set the label text.
	@within SliderBarElement
	@param text string
]=]
function SwitchBarElement:SetLabel(text: string)
	self._label.Value = text
end

function SwitchBarElement:_updateLayout()
	local ELEMENT_HEIGHT = 32
	local paddingWidth = self:GetPadding()

	local label = self._label.Value
	label.Position = UDim2.new(0, 0, 0.5, 0)
	local textSize = TextServiceUtils.getSizeForLabel(label, label.Text)

	local SLIDER_WIDTH = 128
	local slider = self._slider.Value
	slider.Size = UDim2.new(0, SLIDER_WIDTH, 1, 0)
	slider.Position = UDim2.new(0, textSize.X + 4 + 4, 0, 0)

	self:GetSizeValue().Value = Vector3.new(SLIDER_WIDTH + 8 + 4 + paddingWidth * 2 + textSize.X, ELEMENT_HEIGHT, 0)
end

function SwitchBarElement:_render(gui: Instance)
	return Blend.mount(gui, {
		[Blend.Children] = {
			Blend.New("TextButton")({
				Active = true,
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				[Blend.OnEvent("InputBegan")] = function(inputObject: InputObject)
					if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
						self._acceptingInput.Value = true
						self:_updateMovement(inputObject.Position)
						self._maid._cancel = inputObject.Changed:Connect(function()
							if inputObject.UserInputState == Enum.UserInputState.End then
								self._maid._cancel = nil
								self._acceptingInput.Value = false
								self:_updateMovement(inputObject.Position)
							end
						end)
					end
				end,
				[Blend.Children] = {
					self:RenderPadding(),
					Blend.New("TextLabel")({
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundTransparency = 1,
						Font = Enum.Font.FredokaOne,
						FontSize = Enum.FontSize.Size18,
						Position = UDim2.new(0, 0, 0.5, 0),
						Size = UDim2.new(1, 0, 1, 0),
						Text = self._label,
						TextColor3 = self._colorTheming:ObserveColor("Glyph"),
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Center,
						[Blend.Instance] = self._label,
					}),
					Blend.New("Frame")({
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundTransparency = 1,
						[Blend.Instance] = self._slider,
						[Blend.Children] = {
							Blend.New("Frame")({
								AnchorPoint = Vector2.new(0, 0.5),
								Position = UDim2.new(0, 0, 0.5, 0),
								Size = UDim2.new(1, 0, 0, 2),
								BackgroundColor3 = self._colorTheming:ObserveColor("Glyph"),
							}),
							Blend.New("Frame")({
								AnchorPoint = Vector2.new(0.5, 0.5),
								Size = UDim2.new(0, 12, 0, 12),
								BackgroundColor3 = self._colorTheming:ObserveColor("Red"),
								Position = Blend.Spring(
									Blend.Computed(self._value, function(value)
										return UDim2.new(value, 0, 0.5, 0)
									end),
									150
								),
								[Blend.Children] = {
									Blend.New("UICorner")({
										CornerRadius = UDim.new(0, 999),
									}),
								},
							}),
						},
					}),
				},
			}),
		},
	})
end

return SwitchBarElement
