--[=[
	@class WxCombo

	Selectable combo box widget.
]=]

local require = require(script.Parent.loader).load(script)

local IMAGE_ARROW = "rbxassetid://13794403429"

local BaseObject = require("BaseObject")
local ObservableList = require("ObservableList")
local Blend = require("Blend")
local FrondAttrs = require("FrondAttrs")
local WxBackground = require("WxBackground")
local ValueObject = require("ValueObject")
local RxBrioUtils = require("RxBrioUtils")
local Observable = require("Observable")
local Maid = require("Maid")
local Brio = require("Brio")
local GoodSignal = require("GoodSignal")
local Rx = require("Rx")
local WxLabel = require("WxLabel")
local WxColors = require("WxColors")
local FrondConstants = require("FrondConstants")
local ButtonHighlightModel = require("ButtonHighlightModel")

local WxCombo = setmetatable({}, BaseObject)
WxCombo.ClassName = "WxCombo"
WxCombo.__index = WxCombo

function WxCombo.new(obj)
	local self = setmetatable(BaseObject.new(obj), WxCombo)

	self._options = ObservableList.new()
	self._maid:GiveTask(self._options)

	self._backgroundValue = ValueObject.new()
	self._backgroundValue.Value = { WxColors["slate"][600], WxColors["slate"][700] }
	self._maid:GiveTask(self._backgroundValue)

	self._optionChosen = GoodSignal.new()
	self._maid:GiveTask(self._optionChosen)

	self._renderDropdownValue = Instance.new("BoolValue")
	self._renderDropdownValue.Value = false
	self._maid:GiveTask(self._renderDropdownValue)

	self._observeSelectedBrio = Observable.new(function(sub)
		local maid = Maid.new()

		local function optionAdded(option)
			-- Just select first option added for now.
			if not maid._selected then
				maid._selected = Brio.new(option)
				sub:Fire(maid._selected)
			end
		end

		local function optionRemoved(option)
			if maid._selected and maid._selected:GetValue() == option then
				maid._selected = nil
			end
		end

		maid:GiveTask(self._options.ItemAdded:Connect(optionAdded))
		maid:GiveTask(self._options.ItemRemoved:Connect(optionRemoved))

		maid:GiveTask(self._optionChosen:Connect(function(option)
			maid._selected = Brio.new(option)
			sub:Fire(maid._selected)
		end))

		return maid
	end)

	self._selectedValue = ValueObject.fromObservable(self._observeSelectedBrio:Pipe({
		RxBrioUtils.flattenToValueAndNil,
		Rx.defaultsToNil,
	}))
	self._maid:GiveTask(self._selectedValue)

	self._label = self:_makeLabel()
	self._maid:GiveTask(self._selectedValue:Observe():Subscribe(function(text: string?)
		self._label:SetText(text or "")
	end))
	self._maid:GiveTask(self._label)

	self._maid:GiveTask(self:_render():Subscribe(function(gui)
		self.Gui = gui
	end))

	return self
end

-- Create a standard-sized label for this control, to keep things constistent.
function WxCombo:_makeLabel()
	local label = WxLabel.new()
	label:SetTextSize(24)
	label:SetWeight(Enum.FontWeight.SemiBold)
	return label
end

function WxCombo:ObserveSelectedOption() end

function WxCombo:AddOption(option: any)
	return self._options:Add(option)
end

function WxCombo:SetBackground(...)
	self._backgroundValue.Value = { ... }
end

function WxCombo:_render()
	local observeDistance = Blend.Computed(self._renderDropdownValue, function(render: boolean)
		return if render then 0 else -4
	end)
	local observeSpring = Blend.Spring(observeDistance, 45, 0.9)
	local observeSpringSnappedVec2 = Blend.Computed(observeSpring, function(value: number)
		return Vector2.new(0, math.round(value))
	end)

	return Blend.New("Frame")({
		BackgroundTransparency = 1,
		[FrondAttrs.FlowDirection] = FrondConstants.DIRECTION_COLUMN,
		[FrondAttrs.Gap] = 8,
		Blend.New("TextButton")({
			Text = "",
			[Blend.OnEvent("Activated")] = function()
				self._renderDropdownValue.Value = not self._renderDropdownValue.Value
			end,
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
				Blend.New("ImageLabel")({
					[FrondAttrs.Size] = Vector2.new(12, 12),
					[FrondAttrs.Transform] = Vector2.new(2, 1),
					Image = IMAGE_ARROW,
					BackgroundTransparency = 1,
				}),
			},
		}),
		Blend.New("Frame")({
			BackgroundTransparency = 0.1,
			BackgroundColor3 = WxColors["slate"][700],
			Visible = self._renderDropdownValue,
			[FrondAttrs.Padding] = Vector2.new(0, 4),
			[FrondAttrs.FlowDirection] = FrondConstants.DIRECTION_COLUMN,
			[FrondAttrs.Ghost] = true,
			[FrondAttrs.AlignItems] = FrondConstants.ALIGN_STRETCH,
			[FrondAttrs.Transform] = observeSpringSnappedVec2,
			Blend.New("UICorner")({
				CornerRadius = UDim.new(0, 4),
			}),
			self._options:ObserveItemsBrio():Pipe({
				RxBrioUtils.flatMapBrio(function(option: any)
					return Observable.new(function(sub)
						local maid = Maid.new()

						local EDGE_PAD_WIDTH = 48

						local model = ButtonHighlightModel.new()
						maid:GiveTask(model)

						local label = self:_makeLabel()
						label:SetText(option)
						maid:GiveTask(model:ObserveIsMouseOrTouchOver():Subscribe(function(hover: boolean)
							label:SetColor(if hover then WxColors["slate"][50] else WxColors["slate"][400])
						end))
						label:SetWeight(Enum.FontWeight.Medium)
						maid:GiveTask(label)

						sub:Fire(Blend.New("TextButton")({
							[FrondAttrs.Padding] = 0,
							Text = "",
							BackgroundColor3 = Blend.Computed(
								model:ObserveIsMouseOrTouchOver(),
								function(hover: boolean)
									return if hover then WxColors["slate"][500] else WxColors["slate"][700]
								end
							),
							[Blend.Instance] = function(instance: Instance)
								model:SetButton(instance)
							end,
							[Blend.OnEvent("Activated")] = function()
								self._optionChosen:Fire(option)
								self._renderDropdownValue.Value = false
							end,
							Blend.New("Frame")({
								BackgroundTransparency = 1,
								[FrondAttrs.Padding] = Vector2.new(0, 0),
								[FrondAttrs.JustifyContent] = FrondConstants.JUSTIFY_END,
								[FrondAttrs.AlignItems] = FrondConstants.ALIGN_CENTER,
								[FrondAttrs.Ghost] = true,
								[FrondAttrs.WidthP] = 1,
								[FrondAttrs.HeightP] = 1,
								[FrondAttrs.Transform] = Vector2.new(8 - EDGE_PAD_WIDTH/2, 0),
								Blend.New("TextLabel")({
									[FrondAttrs.Size] = Vector2.new(16, 16),
									BackgroundTransparency = 1,
									Text = "X",
									Font = Enum.Font.FredokaOne,
									TextXAlignment = Enum.TextXAlignment.Center,
									TextYAlignment = Enum.TextYAlignment.Center,
									TextColor3 = WxColors["slate"][300],
									Visible = Blend.Computed(self._selectedValue, function(selected)
										return selected == option
									end),
								}),
							}),
							Blend.New("Frame")({
								BackgroundTransparency = 1,
								[FrondAttrs.Width] = 24,
								[FrondAttrs.HeightP] = 1,
							}),
							Blend.New("Frame")({
								BackgroundTransparency = 1,
								[FrondAttrs.Padding] = Vector2.new(0, 12),
								[FrondAttrs.FlowDirection] = FrondConstants.DIRECTION_ROW,
								[FrondAttrs.Gap] = 12,
								[FrondAttrs.AlignItems] = FrondConstants.ALIGN_STRETCH,
								label.Gui,
							}),
							Blend.New("Frame")({
								BackgroundTransparency = 1,
								[FrondAttrs.Width] = EDGE_PAD_WIDTH,
								[FrondAttrs.HeightP] = 1,
							}),
						}))

						return maid
					end)
				end),
			}),
		}),
	})
end

return WxCombo
