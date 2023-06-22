local require = require(game:GetService("ServerScriptService"):FindFirstChild("LoaderUtils", true).Parent).load(script)

local Maid = require("Maid")
local RxFrondUtils = require("RxFrondUtils")
local WxToggle = require("WxToggle")
local WxPane = require("WxPane")

return function(target)
	local maid = Maid.new()

	local myTarget = Instance.new("Frame")
	myTarget.BackgroundTransparency = 1
	myTarget.Position = UDim2.new(0.5, 0, 0.5, 0)
	myTarget.Parent = target
	maid:GiveTask(myTarget)

	local dialog = WxPane.new()
	dialog:SetTitle("Toggles!")
	dialog.Gui.Parent = myTarget
	dialog.Gui.AnchorPoint = Vector2.new(0.5, 0.5)
	maid:GiveTask(dialog)

	for _ = 1, 10 do
		local toggle = WxToggle.new()
		toggle.Gui.Parent = dialog:GetBodySlot()
		maid:GiveTask(toggle)
	end

	maid:GiveTask(RxFrondUtils.mountVirtualFrond(dialog.Gui))

	return function()
		maid:DoCleaning()
	end
end
