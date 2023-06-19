--[=[
	@class RxFrondUtils

	Utils for working with instance-based fronds.
]=]

local require = require(script.Parent.loader).load(script)

local RxInstanceUtils = require("RxInstanceUtils")
local RxBrioUtils = require("RxBrioUtils")
local Rx = require("Rx")
local Observable = require("Observable")
local FlexFrondNode = require("FlexFrondNode")
local Blend = require("Blend")
local Maid = require("Maid")
local FrondAttrs = require("FrondAttrs")
local FrondUtils = require("FrondUtils")
local FrondAttributeUtils = require("FrondAttributeUtils")

local RxFrondUtils = {}

function RxFrondUtils.observeWantsFronding(instance: Instance)
	return Observable.new(function(sub)
		local maid = Maid.new()

		local attributeList: { string } = {}

		local function attributeChanged(attributeName: string, value: any?)
			-- Only care about frondable attributes.
			if not FrondAttributeUtils.isFrondAttribute(attributeName) then
				return
			end
			-- Keep?
			local keepAttribute = value ~= nil
			local index: number? = table.find(attributeList, attributeName)
			if keepAttribute then
				if not index then
					table.insert(attributeList, attributeName)
				end
			else
				if index then
					table.insert(attributeList, attributeName)
				end
			end
			-- If we have at least one attribute that's frondable, we're fronding!
			local isFrondable: boolean = #attributeList > 0
			sub:Fire(isFrondable)
		end

		for attributeName: string, value: any? in instance:GetAttributes() do
			attributeChanged(attributeName, value)
		end
		maid:GiveTask(instance.AttributeChanged:Connect(function(attributeName: string)
			attributeChanged(attributeName, instance:GetAttribute(attributeName))
		end))

		return maid
	end):Pipe({
		Rx.distinct(),
	})
end

function RxFrondUtils.observeWantsFrondingBrio(instance: Instance)
	return RxFrondUtils.observeWantsFronding(instance):Pipe({
		RxBrioUtils.switchToBrio(),
		RxBrioUtils.where(function(isFrond: boolean)
			return isFrond == true
		end),
	})
end

function RxFrondUtils.mountVirtualFrondBrio(instance: Instance, parentFrond: table)
	return RxFrondUtils.observeWantsFrondingBrio(instance):Subscribe(function(brio)
		local topMaid = brio:ToMaid()

		-- This frond :).
		local frond = FlexFrondNode.new()
		topMaid:GiveTask(frond)

		-- Update stats.
		for attributeName, value in instance:GetAttributes() do
			FrondAttrs.runHandlerCoded(frond, attributeName, value)
		end
		topMaid:GiveTask(instance.AttributeChanged:Connect(function(attributeName: string)
			FrondAttrs.runHandlerCoded(frond, attributeName, instance:GetAttribute(attributeName))
		end))

		-- Observe children, if possible.
		topMaid:GiveTask(RxInstanceUtils.observeChildrenOfClassBrio(instance, "GuiBase"):Subscribe(function(subBrio)
			subBrio:ToMaid():GiveTask(RxFrondUtils.mountVirtualFrondBrio(subBrio:GetValue(), frond))
		end))

		-- Mount common properties.
		topMaid:GiveTask(Blend.mount(instance, {
			Size = frond:ObserveSizeUDim2(),
			Position = frond:ObservePositionUDim2(),
		}))

		-- Update!
		if parentFrond then
			-- TODO: Do we bother cleaning this up? Tree should GC anyways.
			topMaid:GiveTask(frond:SetParent(parentFrond))
		else
			-- TODO: Put this somewhere more sensible...
			-- This frond has no parent, so it will always be the root node. Update it here.
			topMaid:GiveTask(FrondUtils.bindComputerPerFrame(frond))
		end
	end)
end

return RxFrondUtils
