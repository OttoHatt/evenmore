--[=[
	@class WxCombo

	Selectable combo box widget.
]=]

local require = require(script.Parent.loader).load(script)

local BaseObject = require("BaseObject")
local Blend = require("Blend")
local Brio = require("Brio")
local ButtonHighlightModel = require("ButtonHighlightModel")
local FrondAttrs = require("FrondAttrs")
local FrondConstants = require("FrondConstants")
local GoodSignal = require("GoodSignal")
local Maid = require("Maid")
local Observable = require("Observable")
local ObservableList = require("ObservableList")
local Rx = require("Rx")
local RxBrioUtils = require("RxBrioUtils")
local ValueObject = require("ValueObject")
local WxDropdown = require("WxDropdown")
local WxLabelUtils = require("WxLabelUtils")
local WxNeoColors = require("WxNeoColors")
local WxTransparencies = require("WxTransparencies")

local WxCombo = setmetatable({}, BaseObject)
WxCombo.ClassName = "WxCombo"
WxCombo.__index = WxCombo

function WxCombo.new(obj)
	local self = setmetatable(BaseObject.new(obj), WxCombo)

	self._dropdown = WxDropdown.new()
	self.Gui = self._dropdown.Gui
	self._maid:GiveTask(self._dropdown)

	self._options = ObservableList.new()
	self._maid:GiveTask(self._options)

	self._optionChosen = GoodSignal.new()
	self._maid:GiveTask(self._optionChosen)

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

	self._maid:GiveTask(self._selectedValue:Observe():Subscribe(function(text: string?)
		self._dropdown:SetText(text or "")
	end))

	self._maid:GiveTask(self._dropdown:ObserveDropdownVisibleBrio():Subscribe(function(brio)
		brio:ToMaid():GiveTask(self:_renderDropdownContents())
	end))

	return self
end

function WxCombo:ObserveSelectedOptionBrio()
	return self._observeSelectedBrio
end

function WxCombo:AddOption(option: any)
	return self._options:Add(option)
end

function WxCombo:_renderDropdownContents()
	local parent: Instance = self._dropdown:GetDropdownSlot()

	return self._options:ObserveItemsBrio():Subscribe(function(brio)
		local maid = brio:ToMaid()
		local option = brio:GetValue()

		local EDGE_PAD_WIDTH = 48

		local model = ButtonHighlightModel.new()
		maid:GiveTask(model)

		-- TODO: Referencing this kinda sucks?
		local label = WxLabelUtils.makeActionLabel()
		label:SetText(option)
		maid:GiveTask(model:ObserveIsMouseOrTouchOver():Subscribe(function(hover: boolean)
			label:SetColor(Color3.new(0, 0, 0))
			label:SetTransparency(if hover then WxTransparencies[900] else WxTransparencies[500])
		end))
		label:SetWeight(Enum.FontWeight.Medium)
		maid:GiveTask(label)

		maid:GiveTask(Blend.New("TextButton")({
			Text = "",
			BackgroundColor3 = Blend.Computed(model:ObserveIsMouseOrTouchOver(), function(hover: boolean)
				return if hover then WxNeoColors.nudes[200] else WxNeoColors.nudes[400]
			end),
			[FrondAttrs.Padding] = 0,
			[Blend.Instance] = function(instance: Instance)
				model:SetButton(instance)
			end,
			[Blend.OnEvent("Activated")] = function()
				self._optionChosen:Fire(option)
				self._dropdown:HideDropdown()
			end,
			Blend.New("Frame")({
				BackgroundTransparency = 1,
				[FrondAttrs.Padding] = Vector2.new(0, 0),
				[FrondAttrs.JustifyContent] = FrondConstants.JUSTIFY_END,
				[FrondAttrs.AlignItems] = FrondConstants.ALIGN_CENTER,
				[FrondAttrs.Ghost] = true,
				[FrondAttrs.WidthP] = 1,
				[FrondAttrs.HeightP] = 1,
				[FrondAttrs.Transform] = Vector2.new(8 - EDGE_PAD_WIDTH / 2, 0),
				Blend.New("TextLabel")({
					[FrondAttrs.Size] = Vector2.new(16, 16),
					BackgroundTransparency = 1,
					Text = "X",
					Font = Enum.Font.FredokaOne,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextYAlignment = Enum.TextYAlignment.Center,
					TextColor3 = Color3.new(0, 0, 0),
					TextTransparency = Blend.Computed(model:ObserveIsMouseOrTouchOver(), function(hover: boolean)
						return if hover then WxTransparencies[400] else WxTransparencies[200]
					end),
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
			Parent = parent,
		}):Subscribe())
	end)
end

return WxCombo
