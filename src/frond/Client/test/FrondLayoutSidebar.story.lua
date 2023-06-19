local require = require(game:GetService("ServerScriptService"):FindFirstChild("LoaderUtils", true).Parent).load(script)

local Maid = require("Maid")
local FlexFrondNode = require("FlexFrondNode")
local FrondUtils = require("FrondUtils")
local Blend = require("Blend")
local BaseFrondNode = require("BaseFrondNode")
local FrondConstants = require("FrondConstants")

local function makeFrondDemo(maid)
	local topNode

	do
		local node = FlexFrondNode.new()
		node:SetSizingX(FrondConstants.SIZING_PIXEL, 512)
		node:SetSizingY(FrondConstants.SIZING_PIXEL, 1024)
		node:SetPaddingXY(8)
		node:SetGap(128)
		maid:GiveTask(node)
		topNode = node
	end
	do
		local node = BaseFrondNode.new()
		node:SetSizingX(FrondConstants.SIZING_PIXEL, 64)
		node:SetSizingY(FrondConstants.SIZING_PIXEL, 64)
		maid:GiveTask(node:SetParent(topNode))
		maid:GiveTask(node)
	end
	do
		local node = BaseFrondNode.new()
		node:SetGrowsToFit(true)
		maid:GiveTask(node:SetParent(topNode))
		maid:GiveTask(node)
	end

	return topNode
end

return function(target)
	local maid = Maid.new()

	maid._frond = makeFrondDemo(maid)
	maid:GiveTask(FrondUtils.bindComputerPerFrame(maid._frond))
	maid:GiveTask(Blend.mount(target, {
		Blend.New("Frame")({
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0, 64),
			FrondUtils.renderFrondNodeRecursive(maid._frond),
		}),
	}))

	return function()
		maid:DoCleaning()
	end
end
