--[=[
	@class RxFrondUtils

	Utils for working with instance-based fronds.
]=]

local require = require(script.Parent.loader).load(script)

local Blend = require("Blend")
local FrondLut = require("FrondLut")
local FrondUtils = require("FrondUtils")
local Maid = require("Maid")

local RxFrondUtils = {}

function RxFrondUtils.mountVirtualFrond(instance: Instance, parentFrond: table)
	-- This frond :).
	local frond = FrondLut:WeakGet(instance)
	if not frond then
		return nil
	end

	local topMaid = Maid.new()

	-- Mount common properties.
	-- TODO: Unsure which order is more performant?
	topMaid:GiveTask(Blend.mount(instance, {
		Size = frond:ObserveSizeUDim2(),
		Position = frond:ObservePositionUDim2(),
	}))

	-- Observe children, if possible.
	local function childAdded(child: Instance)
		-- TODO: Check for "GuiBase" classname?
		topMaid[child] = RxFrondUtils.mountVirtualFrond(child, frond)
	end
	local function childRemoved(child: Instance)
		topMaid[child] = nil
	end
	for _, child in instance:GetChildren() do
		childAdded(child)
	end
	topMaid:GiveTask(instance.ChildAdded:Connect(childAdded))
	topMaid:GiveTask(instance.ChildRemoved:Connect(childRemoved))

	-- Update!
	if parentFrond then
		topMaid:GiveTask(frond:SetParent(parentFrond))
	else
		debug.profilebegin("RxFrondUtils.mountVirtualFrond::compute")
		-- TODO: Put this somewhere more sensible...
		-- This frond has no parent, so it will always be the root node. Update it here.
		topMaid:GiveTask(FrondUtils.bindComputerPerFrame(frond))
		debug.profileend()
	end

	-- GC last, so we destroy the tree bottom-up.
	-- topMaid:GiveTask(frond)

	return topMaid
end

return RxFrondUtils
