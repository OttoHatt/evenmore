local require = require(game:GetService("ServerScriptService"):FindFirstChild("LoaderUtils", true).Parent).load(script)

local Blend = require("Blend")
local FrondAttrs = require("FrondAttrs")
local FrondConstants = require("FrondConstants")
local Maid = require("Maid")
local RxFrondUtils = require("RxFrondUtils")
local WxColorDropdown = require("WxColorDropdown")
local WxDialog = require("WxDialog")
local WxLabelUtils = require("WxLabelUtils")
local WxSlider = require("WxSlider")
local WxToggle = require("WxToggle")

return function(target)
	local maid = Maid.new()

	local t = os.clock()

	debug.profilebegin("WxZoo.story::create")

	local myTarget = Instance.new("Frame")
	myTarget.BackgroundTransparency = 1
	myTarget.Position = UDim2.new(0.5, 0, 0.5, 0)
	myTarget.Parent = target
	maid:GiveTask(myTarget)

	local dialog = WxDialog.new()
	dialog:SetTitle("Widget Zoo!")
	dialog:SetBodyCopy(
		"Hello! This is a collection of examples using the WxWidgets collection. Each element is fully-featured, and offers a reactive interface for easy integration into your games."
	)
	dialog.Gui.Parent = myTarget
	dialog.Gui.AnchorPoint = Vector2.new(0.5, 0.5)
	maid:GiveTask(dialog)

	-- maid:GiveTask(Blend.mount(dialog:GetBodySlot(), {
	-- 	Blend.New"Frame"{
	-- 		[FrondAttrs.WidthP] = 1,
	-- 		[FrondAttrs.Height] = 1,
	-- 		BackgroundColor3 = Color3.new(0,0,0),
	-- 		BackgroundTransparency = 0.95,
	-- 	}
	-- }))

	-- do
	-- 	local label = WxLabelUtils.makeSubTitleLabel()
	-- 	label:SetText("Settings")
	-- 	label.Gui.Parent = dialog:GetBodySlot()
	-- 	maid:GiveTask(label)
	-- end
	do
		local TITLES = table.freeze({
			"Enable sound effects",
			"Enable music",
			"Enable screen-shake",
			"Enable build animations",
		})

		local intances = {}
		for _, title in TITLES do
			local toggle = WxToggle.new()
			toggle:SetText(title)
			maid:GiveTask(toggle)

			table.insert(intances, toggle.Gui)
		end

		local toggle2 = WxToggle.new()
		toggle2:SetText("Enable music")
		maid:GiveTask(toggle2)
		maid:GiveTask(Blend.mount(dialog:GetBodySlot(), {
			Blend.New("Frame")({
				[FrondAttrs.Gap] = 4,
				[FrondAttrs.FlowDirection] = FrondConstants.DIRECTION_COLUMN,
				[Blend.Children] = intances,
			}),
		}))
	end
	-- do
	-- 	local toggle = WxColorDropdown.new()
	-- 	toggle:SetText("Colorpicker")
	-- 	toggle:SetColor(Color3.new(0, 0, 0))
	-- 	toggle.Gui.Parent = dialog:GetBodySlot()
	-- 	maid:GiveTask(toggle:ObserveColor():Subscribe(function(color)
	-- 		toggle:SetBackground(color)
	-- 	end))
	-- 	maid:GiveTask(toggle)
	-- end
	do
		local a = WxSlider.new()
		a.Gui.Parent = dialog:GetBodySlot()
		maid:GiveTask(a)
	end

	debug.profileend()

	debug.profilebegin("WxZoo.story::mount")
	maid:GiveTask(RxFrondUtils.mountVirtualFrond(dialog.Gui))
	debug.profileend()

	print(os.clock() - t)

	return function()
		maid:DoCleaning()
	end
end
