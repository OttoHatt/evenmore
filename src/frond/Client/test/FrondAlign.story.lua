local require = require(game:GetService("ServerScriptService"):FindFirstChild("LoaderUtils", true).Parent).load(script)

local Maid = require("Maid")
local FlexFrondNode = require("FlexFrondNode")
local FrondUtils = require("FrondUtils")
local Blend = require("Blend")
local BaseFrondNode = require("BaseFrondNode")
local FrondConstants = require("FrondConstants")
local GridFondNode = require("GridFondNode")

local function makeTinyNode(maid, alignFlow, alignCross)
	local topNode

	do
		local node = FlexFrondNode.new()
		node:SetPaddingXY(8)
		node:SetAlignFlow(alignFlow)
		node:SetAlignCrossFlow(alignCross)
		node:SetElementPadding(8)
		node:SetSizingXY(FrondConstants.SIZING_SCALE, 1)
		maid:GiveTask(node)
		topNode = node
	end
	for i = 3, 6 do
		local node = BaseFrondNode.new()
		node:SetSizingX(FrondConstants.SIZING_PIXEL, i * 5)
		node:SetSizingY(FrondConstants.SIZING_PIXEL, i * 10)
		maid:GiveTask(node:SetParent(topNode))
		maid:GiveTask(node)
	end

	return topNode
end

local COMBOS = {
	{ FrondConstants.ALIGN_START, FrondConstants.ALIGN_START },
	{ FrondConstants.ALIGN_MIDDLE, FrondConstants.ALIGN_START },
	{ FrondConstants.ALIGN_END, FrondConstants.ALIGN_START },
	{ FrondConstants.ALIGN_START, FrondConstants.ALIGN_MIDDLE },
	{ FrondConstants.ALIGN_MIDDLE, FrondConstants.ALIGN_MIDDLE },
	{ FrondConstants.ALIGN_END, FrondConstants.ALIGN_MIDDLE },
	{ FrondConstants.ALIGN_START, FrondConstants.ALIGN_END },
	{ FrondConstants.ALIGN_MIDDLE, FrondConstants.ALIGN_END },
	{ FrondConstants.ALIGN_END, FrondConstants.ALIGN_END },
}

local function makeMainNode(maid)
	local topNode

	do
		local node = GridFondNode.new()
		node:SetSizingX(FrondConstants.SIZING_PIXEL, 1024 * 1)
		node:SetElementsPerRow(4)
		node:SetElementPadding(8)
		maid:GiveTask(node)
		topNode = node
	end

	for _, combo in COMBOS do
		local node = makeTinyNode(maid, table.unpack(combo))
		maid:GiveTask(node:SetParent(topNode))
	end
	for _, combo in COMBOS do
		local node = makeTinyNode(maid, table.unpack(combo))
		maid:GiveTask(node:SetParent(topNode))
		node:SetFlowDirection(FrondConstants.DIRECTION_COLUMN)
	end

	return topNode
end

return function(target)
	local maid = Maid.new()

	maid._frond = makeMainNode(maid)
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
