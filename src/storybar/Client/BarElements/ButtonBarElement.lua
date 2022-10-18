--[=[
	@class ButtonBarElement
	@private

	Clickable button that slots into a [StoryBar].
	You won't want to create this directly; see [StoryBarUtils].

	![Button Gif](/evenmore/storybar/button.gif)
]=]

local require = require(script.Parent.loader).load(script)

local BaseBarElement = require("BaseBarElement")
local Blend = require("Blend")
local Signal = require("Signal")
local TextServiceUtils = require("TextServiceUtils")

local ButtonBarElement = setmetatable({}, BaseBarElement)
ButtonBarElement.ClassName = "ButtonBarElement"
ButtonBarElement.__index = ButtonBarElement

function ButtonBarElement.new(serviceBag)
	local self = setmetatable(BaseBarElement.new(serviceBag), ButtonBarElement)

	self.Pressed = Signal.new()
	self._maid:GiveTask(self.Pressed)

	self._label = Instance.new("StringValue")
	self._label.Value = "Button"
	self._maid:GiveTask(self._label)

	self._label = Instance.new("ObjectValue")
	self._maid:GiveTask(self._label)

	self._maid:GiveTask(self:_render(self.Gui))

	self:_updateSize()
	self._maid:GiveTask(self.Gui.AncestryChanged:Connect(function()
		self:_updateSize()
	end))

	return self
end

--[=[
	Signal that's fired when the button is clicked.
	@prop Pressed Signal
	@readonly
	@within ButtonBarElement
]=]

--[=[
	Set the label text.
	@within ButtonBarElement
	@param text string
]=]
function ButtonBarElement:SetLabel(text: string)
	self._label.Value = text
end

function ButtonBarElement:_updateSize()
	local paddingWidth = self:GetPadding()

	local label = self._label.Value
	local textSize = TextServiceUtils.getSizeForLabel(label, label.Text)

	self:GetSizeValue().Value = Vector3.new(paddingWidth * 2 + textSize.X, 32, 0)
end

function ButtonBarElement:_render(gui: Instance)
	return Blend.mount(gui, {
		[Blend.Children] = {
			Blend.New("TextButton")({
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				[Blend.OnEvent("Activated")] = function()
					self.Pressed:Fire()
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
				},
			}),
		},
	})
end

return ButtonBarElement
