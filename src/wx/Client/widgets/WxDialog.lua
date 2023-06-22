--[=[
	@class WxDialog

	Wx dialog / modal component.
]=]

local require = require(script.Parent.loader).load(script)

local BaseObject = require("BaseObject")
local Blend = require("Blend")
local WxButton = require("WxButton")
local WxCombo = require("WxCombo")
local WxPane = require("WxPane")
local WxNeoColors = require("WxNeoColors")
local WxLabelUtils = require("WxLabelUtils")

local WxDialog = setmetatable({}, BaseObject)
WxDialog.ClassName = "WxDialog"
WxDialog.__index = WxDialog

function WxDialog.new(obj)
	local self = setmetatable(BaseObject.new(obj), WxDialog)

	self._pane = WxPane.new()
	self.Gui = self._pane.Gui
	self._maid:GiveTask(self._pane)

	self._bodyCopy = WxLabelUtils.makeBodyLabel()
	self._bodyCopy:SetMaxWidth(490)
	self._maid:GiveTask(self._bodyCopy)

	self._maid:GiveTask(self:_renderBody(self._pane:GetBodySlot()))
	self._maid:GiveTask(self:_renderFooter(self._pane:GetFooterSlot()))

	return self
end

function WxDialog:SetTitle(...)
	self._pane:SetTitle(...)
end

function WxDialog:SetBodyCopy(...)
	self._bodyCopy:SetText(...)
end

function WxDialog:GetBodySlot()
	return self._pane:GetBodySlot()
end

function WxDialog:_renderBody(target: Instance)
	return Blend.mount(target, {
		self._bodyCopy.Gui,
	})
end

function WxDialog:_renderFooter(target: Instance)
	local button1 = WxButton.new()
	button1:SetText("I'm Sure!")
	button1:SetBackground(WxNeoColors.danger[400])
	self._maid:GiveTask(button1)

	local button2 = WxButton.new()
	button2:SetText("Cancel")
	button2:SetBackground(WxNeoColors.nudes[400])
	self._maid:GiveTask(button2)

	-- local button3 = WxButton.new()
	-- button3:SetText("?")
	-- button3:SetBackground(WxNeoColors.success[500])
	-- self._maid:GiveTask(button3)

	local combo = WxCombo.new()
	self._maid:GiveTask(combo:AddOption("Lynel"))
	self._maid:GiveTask(combo:AddOption("Guardian Stalker"))
	self._maid:GiveTask(combo:AddOption("Chuchu"))
	self._maid:GiveTask(combo:AddOption("Bokoblin"))
	self._maid:GiveTask(combo)

	return Blend.mount(target, {
		button1.Gui,
		button2.Gui,
		-- button3.Gui,
		combo.Gui,
	})
end

return WxDialog
