--[=[
	@class WxInteractUtils

	Utils for working with Wx interactions.
]=]

local require = require(script.Parent.loader).load(script)

local TAG_TRAY = "WxInteractionTray"
local ATTRIBUTE_CURRENT_HANDLE = "WxSelectionHandle"

local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")

local CollectionServiceUtils = require("CollectionServiceUtils")
local RxAttributeUtils = require("RxAttributeUtils")
local RxBrioUtils = require("RxBrioUtils")
local Rx = require("Rx")
local Observable = require("Observable")
local Maid = require("Maid")
local Brio = require("Brio")

local WxInteractUtils = {}

function WxInteractUtils.markAsTray(instance: Instance)
	CollectionService:AddTag(instance, TAG_TRAY)
	return function()
		instance:SetAttribute(ATTRIBUTE_CURRENT_HANDLE, nil)
		CollectionService:RemoveTag(instance, TAG_TRAY)
	end
end

function WxInteractUtils.makeHandle(): string
	return HttpService:GenerateGUID(false)
end

local function observeFirstTaggedAncestorBrio(tagName: string, child: Instance)
	assert(type(tagName) == "string", "Bad tagName")
	assert(typeof(child) == "Instance", "Bad instance")

	return Observable.new(function(sub)
		local maid = Maid.new()

		local handleAdded, handleRemoved

		local function setSelection(instance: Instance?)
			-- Hook brio.
			if instance then
				maid._brio = Brio.new(instance)
				sub:Fire(maid._brio)
			else
				maid._brio = nil
			end
			-- Hook one callback at a time.
			-- Only listen to added instances if we haven't got a selection.
			-- Only listened to removed instances if we do have a selection.
			if instance then
				maid._cb = CollectionService:GetInstanceAddedSignal(tagName):Connect(handleAdded)
			else
				maid._cb = CollectionService:GetInstanceRemovedSignal(tagName):Connect(handleRemoved)
			end
		end

		handleAdded = function(instance: Instance)
			-- Sometimes CollectionService fires twice...
			if maid._brio and maid._brio:GetValue() == instance then
				return
			end
			-- We're only looking at ancestors!
			if instance:IsAncestorOf(child) then
				if maid._brio then
					-- Do we already have an instance selected?
					-- If our newly found instance is below our current selection, prioritise it!
					-- Otherwise, just ignore it. We want the closest ancestor.
					if instance:IsDescendantOf(maid._brio:GetValue()) then
						setSelection(instance)
					end
				else
					-- If we have no current selection, always select.
					setSelection(instance)
				end
			end
		end

		handleRemoved = function(instance: Instance?)
			if maid._brio and maid._brio:GetValue() == instance then
				-- Our selected instance has been removed! :(
				setSelection(nil)
			end
		end

		-- Always listen to .AncestryChanged! This should be quite cheap anyways, fires rarely.
		local function checkAncestry()
			local candidate: Instance? = CollectionServiceUtils.findFirstAncestor(tagName, child)
			if candidate then
				handleAdded(candidate)
			end
		end
		maid:GiveTask(child.AncestryChanged:Connect(checkAncestry))
		checkAncestry()

		return maid
	end)
end

function WxInteractUtils.observeTrayInstanceBrio(child: Instance)
	return observeFirstTaggedAncestorBrio(TAG_TRAY, child)
end

local function observeTrayHasSelectedBrio(tray: Instance, handle: string)
	assert(typeof(tray) == "Instance", "Bad tray")
	assert(typeof(handle) == "string", "Bad handle")

	return RxAttributeUtils.observeAttribute(tray, ATTRIBUTE_CURRENT_HANDLE):Pipe({
		Rx.map(function(topHandle: string?)
			return topHandle == handle
		end),
		Rx.distinct(),
		RxBrioUtils.switchToBrio(),
		RxBrioUtils.where(function(value: boolean)
			return value == true
		end),
	})
end

function WxInteractUtils.observeSelectionBrio(child: Instance, handle: string)
	assert(typeof(child) == "Instance", "Bad child")
	assert(typeof(handle) == "string", "Bad handle")

	return WxInteractUtils.observeTrayInstanceBrio(child):Pipe({
		RxBrioUtils.switchMapBrio(function(tray: Instance)
			return observeTrayHasSelectedBrio(tray, handle)
		end),
	})
end

function WxInteractUtils.observeSelectionBool(child: Instance, handle: string)
	return WxInteractUtils.observeSelectionBrio(child, handle):Pipe({
		RxBrioUtils.map(function()
			return true
		end),
		RxBrioUtils.emitOnDeath(false),
		Rx.defaultsTo(false),
	})
end

function WxInteractUtils.pushSelection(child: Instance, handle: string)
	assert(typeof(child) == "Instance", "Bad child")
	assert(typeof(handle) == "string", "Bad handle")

	local tray: Instance? = CollectionServiceUtils.findFirstAncestor(TAG_TRAY, child)
	assert(tray, "Bad instance; has no ancestor interaction tray!")

	tray:SetAttribute(ATTRIBUTE_CURRENT_HANDLE, handle)

	return function()
		-- Only respect cleaning up if we're currently selected.
		if tray:GetAttribute(ATTRIBUTE_CURRENT_HANDLE) == handle then
			tray:SetAttribute(ATTRIBUTE_CURRENT_HANDLE, nil)
		end
	end
end

function WxInteractUtils.clearSelection(child: Instance, handle: string)
	assert(typeof(child) == "Instance", "Bad child")
	assert(typeof(handle) == "string", "Bad handle")

	local tray: Instance? = CollectionServiceUtils.findFirstAncestor(TAG_TRAY, child)
	assert(tray, "Bad instance; has no ancestor interaction tray!")

	if tray:GetAttribute(ATTRIBUTE_CURRENT_HANDLE) == handle then
		tray:SetAttribute(ATTRIBUTE_CURRENT_HANDLE, nil)
	end
end

function WxInteractUtils.toggleSelection(child: Instance, handle: string)
	assert(typeof(child) == "Instance", "Bad child")
	assert(typeof(handle) == "string", "Bad handle")

	local tray: Instance? = CollectionServiceUtils.findFirstAncestor(TAG_TRAY, child)
	assert(tray, "Bad instance; has no ancestor interaction tray!")

	if tray:GetAttribute(ATTRIBUTE_CURRENT_HANDLE) == handle then
		tray:SetAttribute(ATTRIBUTE_CURRENT_HANDLE, nil)
	else
		tray:SetAttribute(ATTRIBUTE_CURRENT_HANDLE, handle)
	end
end

return WxInteractUtils
