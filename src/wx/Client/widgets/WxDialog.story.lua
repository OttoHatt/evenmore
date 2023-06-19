local require = require(game:GetService("ServerScriptService"):FindFirstChild("LoaderUtils", true).Parent).load(script)

local Maid = require("Maid")
local WxDialog = require("WxDialog")
local RxFrondUtils = require("RxFrondUtils")
local FrondManagedUtils = require("FrondManagedUtils")
local FrondConstants = require("FrondConstants")
local FrondUtils = require("FrondUtils")

return function(target)
	local maid = Maid.new()

	-- local rootFrond = FrondManagedUtils.mountFrond(target)
	-- rootFrond:SetAlignFlow(FrondConstants.ALIGN_MIDDLE)
	-- rootFrond:SetAlignCrossFlow(FrondConstants.ALIGN_MIDDLE)
	-- maid:GiveTask(rootFrond)
	local myTarget = Instance.new("Frame")
	myTarget.BackgroundTransparency = 1
	myTarget.Position = UDim2.new(0.5, 0, 0.5, 0)
	myTarget.Parent = target
	maid:GiveTask(myTarget)

	local dialog = WxDialog.new()
	dialog:SetTitle("Delete?")
	dialog:SetBodyCopy("Are you sure you want to delete this item? This cannot be undone!")
	dialog.Gui.Parent = myTarget
	dialog.Gui.AnchorPoint = Vector2.new(0.5, 0.5)
	maid:GiveTask(dialog)

	maid:GiveTask(RxFrondUtils.mountVirtualFrondBrio(dialog.Gui))

	return function()
		maid:DoCleaning()
	end
end
