local require = require(game:GetService("ServerScriptService"):FindFirstChild("LoaderUtils", true).Parent).load(script)

local Maid = require("Maid")
local FrondUtils = require("FrondUtils")
local FlexFrondNode = require("FlexFrondNode")
local BaseFrondNode = require("BaseFrondNode")
local FrondConstants = require("FrondConstants")
local Blend = require("Blend")
local StoryBarUtils = require("StoryBarUtils")
local Math = require("Math")

local RANDOM = Random.new()

local function makeFrondDemo(...)
	local maid, elemPaddingSlider, boxPaddingSlider, boxLengthSlider, depth: number? = ...
	depth = if depth then depth + 1 else 0

	local topNode
	do
		local node = FlexFrondNode.new()
		node:SetSizingX(FrondConstants.SIZING_UNSET, nil)
		node:SetSizingY(FrondConstants.SIZING_UNSET, nil)
		node:SetPaddingXY(32)

		if RANDOM:NextNumber() > 0.5 then
			node:SetFlowDirection(FrondConstants.DIRECTION_COLUMN)
		else
			node:SetFlowDirection(FrondConstants.DIRECTION_ROW)
		end
		maid:GiveTask(elemPaddingSlider:Observe():Subscribe(function(value)
			node:SetGap(value * 64)
		end))
		maid:GiveTask(boxPaddingSlider:Observe():Subscribe(function(value)
			node:SetPaddingXY(value * 64)
		end))
		maid:GiveTask(node)
		topNode = node
	end
	for _ = 1, 4 do
		if RANDOM:NextNumber() > 0.2 and depth < 4 then
			local node = BaseFrondNode.new()
			node:SetSizingX(FrondConstants.SIZING_PIXEL, 50)
			local fac = RANDOM:NextNumber()
			maid:GiveTask(boxLengthSlider:Observe():Subscribe(function(value)
				node:SetSizingY(FrondConstants.SIZING_PIXEL, Math.map(value, 0, 1, 50, 50 + 200 * fac))
			end))
			maid:GiveTask(node:SetParent(topNode))
			maid:GiveTask(node)
		else
			local node = makeFrondDemo(...)
			maid:GiveTask(node:SetParent(topNode))
			maid:GiveTask(node)
		end
	end
	do
		local node = BaseFrondNode.new()
		node:SetSizingX(FrondConstants.SIZING_PIXEL, 8)
		node:SetSizingY(FrondConstants.SIZING_SCALE, 1)
		maid:GiveTask(node:SetParent(topNode))
		maid:GiveTask(node)
	end
	do
		local node = BaseFrondNode.new()
		node:SetSizingX(FrondConstants.SIZING_PIXEL, 32)
		node:SetSizingY(FrondConstants.SIZING_SCALE, 0.5)
		maid:GiveTask(node:SetParent(topNode))
		maid:GiveTask(node)
	end

	return topNode
end

return function(target)
	local topMaid = Maid.new()

	local bar = StoryBarUtils.createStoryBar(topMaid, target)
	local elemPaddingSlider = StoryBarUtils.createSlider(bar, "F Pdg", 0.5)
	local boxPaddingSlider = StoryBarUtils.createSlider(bar, "B Pdg", 0.5)
	local boxLengthSlider = StoryBarUtils.createSlider(bar, "B Len", 0.5)

	local function refresh()
		local maid = Maid.new()
		topMaid._frondMaid = maid

		maid._frond = makeFrondDemo(maid, elemPaddingSlider, boxPaddingSlider, boxLengthSlider)
		maid:GiveTask(FrondUtils.bindComputerPerFrame(maid._frond))
		maid:GiveTask(Blend.mount(target, {
			Blend.New("Frame")({
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 0, 64),
				FrondUtils.renderFrondNodeRecursive(maid._frond),
			}),
		}))
	end
	StoryBarUtils.createButton(bar, "Refresh", refresh)
	refresh()

	return function()
		topMaid:DoCleaning()
	end
end
