--[=[
	@class WxDropdown

	Composable dropdown widget.
]=]

local require = require(script.Parent.loader).load(script)

local IMAGE_ARROW = "rbxassetid://13794403429"

local UserInputService = game:GetService("UserInputService")

local BaseObject = require("BaseObject")
local Blend = require("Blend")
local FrondAttrs = require("FrondAttrs")
local FrondConstants = require("FrondConstants")
local RxBrioUtils = require("RxBrioUtils")
local ValueObject = require("ValueObject")
local WxBackground = require("WxBackground")
local WxLabel = require("WxLabel")
local WxLabelUtils = require("WxLabelUtils")
local WxNeoColors = require("WxNeoColors")

local WxDropdown = setmetatable({}, BaseObject)
WxDropdown.ClassName = "WxDropdown"
WxDropdown.__index = WxDropdown

function WxDropdown.new(obj)
	local self = setmetatable(BaseObject.new(obj), WxDropdown)

	self._backgroundValue = ValueObject.new()
	self._backgroundValue.Value = { WxNeoColors.nudes[600] }
	self._maid:GiveTask(self._backgroundValue)

	self._renderDropdownValue = ValueObject.new(false, "boolean")
	self._maid:GiveTask(self._renderDropdownValue)

	self._dropdownValue = Instance.new("ObjectValue")
	self._maid:GiveTask(self._dropdownValue)

	self._textSlotValue = Instance.new("ObjectValue")
	self._maid:GiveTask(self._textSlotValue)

	self._label = WxLabelUtils.makeActionLabel()
	self._maid:GiveTask(self._label)

	self._maid:GiveTask(self:_render():Subscribe(function(gui)
		self.Gui = gui
	end))

	return self
end

function WxDropdown:SetBackground(...)
	self._backgroundValue.Value = { ... }
end

function WxDropdown:SetText(title: string)
	self._label:SetText(title)
end

function WxDropdown:ShowDropdown()
	self._renderDropdownValue.Value = true
end

function WxDropdown:HideDropdown()
	self._renderDropdownValue.Value = false
end

function WxDropdown:ToggleDropdown()
	self._renderDropdownValue.Value = not self._renderDropdownValue.Value
end

function WxDropdown:GetTextSlot()
	return self._textSlotValue.Value
end

function WxDropdown:GetDropdownSlot()
	return self._dropdownValue.Value
end

function WxDropdown:ObserveDropdownVisible()
	return self._renderDropdownValue:Observe()
end

function WxDropdown:ObserveDropdownVisibleBrio()
	return self._renderDropdownValue:Observe():Pipe({
		RxBrioUtils.switchToBrio(),
		RxBrioUtils.where(function(visible: boolean)
			return visible == true
		end),
	})
end

local function isOutOfBounds(gui: GuiBase2d, point: Vector3)
	local worldPosition = gui.AbsolutePosition
	local worldSize: Vector2 = gui.AbsoluteSize

	local offset = Vector3.new(point.X - worldPosition.X, point.Y - worldPosition.Y)

	return offset.X < 0 or offset.X > worldSize.X or offset.Y < 0 or offset.Y > worldSize.Y
end

function WxDropdown:_render()
	local observeDistance = Blend.Computed(self._renderDropdownValue, function(render: boolean)
		return if render then 0 else -4
	end)
	local observeSpring = Blend.Spring(observeDistance, 45, 0.9)
	local observeSpringSnappedVec2 = Blend.Computed(observeSpring, function(value: number)
		return Vector2.new(0, math.round(value))
	end)

	self._maid:GiveTask(self:ObserveDropdownVisibleBrio():Subscribe(function(brio)
		local maid = brio:ToMaid()

		maid:GiveTask(UserInputService.InputBegan:Connect(function(input: InputObject, _gameProcessed: boolean)
			-- We intentionally catch 'gameProcessed' events, as this could be clicking on other GUIs.
			-- Ensure mouse click was totally outside of our element.
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				and isOutOfBounds(self:GetDropdownSlot(), input.Position)
				and isOutOfBounds(self.Gui, input.Position)
			then
				maid._unclick = input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						self:HideDropdown()
					end
				end)
			end
		end))
	end))

	return Blend.New("Frame")({
		BackgroundTransparency = 1,
		ZIndex = Blend.Computed(self._renderDropdownValue, function(render: boolean)
			return if render then 99 else 1
		end),
		[FrondAttrs.FlowDirection] = FrondConstants.DIRECTION_COLUMN,
		[FrondAttrs.Gap] = 8,
		Blend.New("TextButton")({
			Text = "",
			[Blend.OnEvent("Activated")] = function()
				self:ToggleDropdown()
			end,
			[Blend.Instance] = self._textSlotValue,
			[FrondAttrs.Padding] = Vector2.new(24, 12),
			[FrondAttrs.FlowDirection] = FrondConstants.DIRECTION_ROW,
			[FrondAttrs.AlignItems] = FrondConstants.ALIGN_CENTER,
			[FrondAttrs.Gap] = 8,
			[WxBackground.Polymorphic] = self._backgroundValue,
			[Blend.Children] = {
				Blend.New("UICorner")({
					CornerRadius = UDim.new(0, 4),
				}),
				self._label.Gui,
				Blend.New("Frame")({
					BackgroundTransparency = 1,
					[FrondAttrs.Size] = Vector2.new(12, 12),
					[FrondAttrs.Transform] = Blend.Computed(self._renderDropdownValue, function(render: boolean)
						return if render then Vector2.new(2, 1) else Vector2.new(2, 0)
					end),
					Blend.New("ImageLabel")({
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.new(1, 0, 1, 0),
						Image = IMAGE_ARROW,
						BackgroundTransparency = 1,
						Rotation = Blend.Computed(self._renderDropdownValue, function(render: boolean)
							return if render then 180 else 0
						end),
					}),
				}),
			},
		}),
		Blend.New("Frame")({
			BackgroundTransparency = 0,
			BackgroundColor3 = WxNeoColors.nudes[400],
			Visible = self._renderDropdownValue,
			[FrondAttrs.Padding] = Vector2.new(0, 4),
			[FrondAttrs.FlowDirection] = FrondConstants.DIRECTION_COLUMN,
			[FrondAttrs.Ghost] = true,
			[FrondAttrs.AlignItems] = FrondConstants.ALIGN_STRETCH,
			[FrondAttrs.Transform] = observeSpringSnappedVec2,
			[Blend.Instance] = self._dropdownValue,
			Blend.New("UICorner")({
				CornerRadius = UDim.new(0, 4),
			}),
		}),
	})
end

return WxDropdown
