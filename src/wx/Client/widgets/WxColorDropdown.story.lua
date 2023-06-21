local require = require(game:GetService("ServerScriptService"):FindFirstChild("LoaderUtils", true).Parent).load(script)

local Maid = require("Maid")
local RxFrondUtils = require("RxFrondUtils")
local WxColorDropdown = require("WxColorDropdown")
local WxPane = require("WxPane")
local WxInteractUtils = require("WxInteractUtils")

return function(target)
	local maid = Maid.new()

	local t = os.clock()

	debug.profilebegin("WxColorDropdown.story")

	debug.profilebegin("WxColorDropdown.story::Instantiate")

	local myTarget = Instance.new("Frame")
	myTarget.BackgroundTransparency = 1
	myTarget.Position = UDim2.new(0.5, 0, 0.5, 0)
	myTarget.Parent = target
	maid:GiveTask(WxInteractUtils.markAsTray(myTarget))
	maid:GiveTask(myTarget)

	local dialog = WxPane.new()
	dialog:SetTitle("Toggles!")
	dialog.Gui.Parent = myTarget
	dialog.Gui.AnchorPoint = Vector2.new(0.5, 0.5)
	maid:GiveTask(dialog)

	for _ = 1, 10 do
		local dropdown = WxColorDropdown.new()
		dropdown.Gui.Parent = dialog:GetBodySlot()
		maid:GiveTask(dropdown)
	end

	debug.profileend()

	debug.profilebegin("WxColorDropdown.story::Mount")
	maid:GiveTask(RxFrondUtils.mountVirtualFrondBrio(dialog.Gui))
	debug.profileend()

	debug.profileend()

	print(os.clock() - t)

	return function()
		maid:DoCleaning()
	end
end
