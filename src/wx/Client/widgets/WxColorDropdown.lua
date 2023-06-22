--[=[
	@class WxColorDropdown

	Color picker widget.
]=]

local require = require(script.Parent.loader).load(script)

local BaseObject = require("BaseObject")
local WxDropdown = require("WxDropdown")
local Blend = require("Blend")
local HSVColorPicker = require("HSVColorPicker")
local Maid = require("Maid")
local FrondAttrs = require("FrondAttrs")
local ValueObject = require("ValueObject")

local WxColorDropdown = setmetatable({}, BaseObject)
WxColorDropdown.ClassName = "WxColorDropdown"
WxColorDropdown.__index = WxColorDropdown

function WxColorDropdown.new(obj)
	local self = setmetatable(BaseObject.new(obj), WxColorDropdown)

	self._dropdown = WxDropdown.new()
	self.Gui = self._dropdown.Gui
	self._maid:GiveTask(self._dropdown)

	self._colorValue = ValueObject.new(Color3.new(1,1,1), "Color3")
	self._maid:GiveTask(self._colorValue)
	self.ColorChanged = self._colorValue.Changed

	self._maid:GiveTask(self:_renderDropdownContents())

	return self
end

function WxColorDropdown:SetColor(color: Color3)
	self._colorValue.Value = color
end

function WxColorDropdown:ObserveColor()
	return self._colorValue:Observe()
end

function WxColorDropdown:SetText(...)
	self._dropdown:SetText(...)
end

function WxColorDropdown:SetBackground(...)
	self._dropdown:SetBackground(...)
end

function WxColorDropdown:_renderDropdownContents()
	return self._dropdown:ObserveDropdownVisible():Subscribe(function(isVisible)
		if isVisible then
			local maid = Maid.new()
			self._maid._renderMaid = maid

			local input = HSVColorPicker.new()
			maid:GiveTask(input:SyncValue(self._colorValue))
			maid:GiveTask(input)

			maid:GiveTask(Blend.mount(self._dropdown:GetDropdownSlot(), {
				[FrondAttrs.Padding] = 8,
				Blend.New("Frame")({
					BackgroundTransparency = 1,
					[FrondAttrs.Size] = Blend.Computed(input:GetMeasureValue(), function(size: any)
						return size * 64
					end),
					input.Gui,
				}),
			}))
		else
			self._maid._renderMaid = nil
		end
	end)
end

return WxColorDropdown