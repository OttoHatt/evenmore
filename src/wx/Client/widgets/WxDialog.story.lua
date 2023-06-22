local require = require(game:GetService("ServerScriptService"):FindFirstChild("LoaderUtils", true).Parent).load(script)

local Maid = require("Maid")
local WxDialog = require("WxDialog")
local RxFrondUtils = require("RxFrondUtils")

return function(target)
	local maid = Maid.new()

	local t = os.clock()

	debug.profilebegin("WxDialog.story")

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

	maid:GiveTask(RxFrondUtils.mountVirtualFrond(dialog.Gui))

	debug.profileend()

	print(os.clock() - t)

	return function()
		maid:DoCleaning()
	end
end
