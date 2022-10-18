--[=[
	@class SwitchBarElement
	@private

	Like a [ButtonBarElement], but with a toggleable state. Slots into a [StoryBar].
	You won't want to create this directly; see [StoryBarUtils].

	![Switch Gif](/evenmore/storybar/switch.gif)
]=]

local require = require(script.Parent.loader).load(script)

local BaseBarElement = require("BaseBarElement")
local Blend = require("Blend")
local RxValueBaseUtils = require("RxValueBaseUtils")
local TextServiceUtils = require("TextServiceUtils")

local SwitchBarElement = setmetatable({}, BaseBarElement)
SwitchBarElement.ClassName = "SwitchBarElement"
SwitchBarElement.__index = SwitchBarElement

function SwitchBarElement.new(serviceBag)
	local self = setmetatable(BaseBarElement.new(serviceBag), SwitchBarElement)

	self._labelText = Instance.new("StringValue")
	self._labelText.Value = "Switch"
	self._maid:GiveTask(self._labelText)

	self._value = Instance.new("BoolValue")
	self._value.Value = false
	self._maid:GiveTask(self._value)

	self._blip = Instance.new("ObjectValue")
	self._maid:GiveTask(self._blip)

	self._label = Instance.new("ObjectValue")
	self._maid:GiveTask(self._label)

	self._maid:GiveTask(self:_render(self.Gui))

	self:_updateLayout()
	self._maid:GiveTask(self.Gui.AncestryChanged:Connect(function()
		self:_updateLayout()
	end))

	return self
end

--[=[
	Set the switch's current value.
	@private
	@within SwitchBarElement
	@return boolean
]=]
function SwitchBarElement:SetValue(value: boolean)
	self._value.Value = value
end

--[=[
	Get the switch's current value.
	@within SwitchBarElement
	@return boolean
]=]
function SwitchBarElement:GetValue()
	return self._value.Value
end

--[=[
	Observe the switch's current value.
	@within SwitchBarElement
	@return Observable<boolean>
]=]
function SwitchBarElement:Observe()
	return RxValueBaseUtils.observeValue(self._value)
end

--[=[
	Set the label text.
	@within SwitchBarElement
	@param text string
]=]
function SwitchBarElement:SetLabel(text: string)
	self._labelText.Value = text
end

function SwitchBarElement:_updateLayout()
	local paddingWidth = self:GetPadding()

	local elemHeight = 32
	local contentHeight = elemHeight - paddingWidth * 2

	local BLIP_RADIUS = 8
	local BLIP_GAP = 4
	local blip = self._blip.Value
	blip.Size = UDim2.fromOffset(BLIP_RADIUS, BLIP_RADIUS)
	blip.Position = UDim2.fromOffset(BLIP_RADIUS / 2, contentHeight / 2)

	local label = self._label.Value
	label.Position = UDim2.new(0, BLIP_RADIUS + BLIP_GAP, 0.5, 0)
	local textSize = TextServiceUtils.getSizeForLabel(label, label.Text)

	self:GetSizeValue().Value = Vector3.new(BLIP_RADIUS + BLIP_GAP + paddingWidth * 2 + textSize.X, elemHeight, 0)
end

function SwitchBarElement:_render(gui: Instance)
	return Blend.mount(gui, {
		[Blend.Children] = {
			Blend.New("TextButton")({
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				[Blend.OnEvent("Activated")] = function()
					self:SetValue(not self:GetValue())
				end,
				[Blend.Children] = {
					self:RenderPadding(),
					Blend.New("Frame")({
						AnchorPoint = Vector2.one / 2,
						BackgroundColor3 = self._colorTheming:ObserveColor(
							"Red",
							Blend.Spring(
								Blend.Computed(self._value, function(value)
									return if value then 40 else 20
								end),
								100
							)
						),
						[Blend.Instance] = self._blip,
						[Blend.Children] = {
							Blend.New("UICorner")({
								CornerRadius = UDim.new(0, 999),
							}),
						},
					}),
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
				},
			}),
		},
	})
end

return SwitchBarElement
