--[=[
	@class RxFrondUtils

	Utils for working with instance-based fronds.
]=]

local require = require(script.Parent.loader).load(script)

local RxInstanceUtils = require("RxInstanceUtils")
local Blend = require("Blend")
local Maid = require("Maid")
local FrondUtils = require("FrondUtils")
local FrondLut = require("FrondLut")

local RxFrondUtils = {}

function RxFrondUtils.mountVirtualFrondBrio(instance: Instance, parentFrond: table)
	local topMaid = Maid.new()

	-- This frond :).
	local frond = FrondLut:WeakGet(instance)
	if not frond then
		return topMaid
	end

	-- Mount common properties.
	topMaid:GiveTask(Blend.mount(instance, {
		Size = frond:ObserveSizeUDim2(),
		Position = frond:ObservePositionUDim2(),
	}))

	-- Observe children, if possible.
	topMaid:GiveTask(RxInstanceUtils.observeChildrenOfClassBrio(instance, "GuiBase"):Subscribe(function(subBrio)
		subBrio:ToMaid():GiveTask(RxFrondUtils.mountVirtualFrondBrio(subBrio:GetValue(), frond))
	end))

	-- Update!
	if parentFrond then
		-- TODO: Do we bother cleaning this up? Tree should GC anyways.
		topMaid:GiveTask(frond:SetParent(parentFrond))
	else
		-- TODO: Put this somewhere more sensible...
		-- This frond has no parent, so it will always be the root node. Update it here.
		topMaid:GiveTask(FrondUtils.bindComputerPerFrame(frond))
	end

	-- GC last, so we destroy the tree bottom-up.
	-- topMaid:GiveTask(frond)

	return topMaid
end

return RxFrondUtils
