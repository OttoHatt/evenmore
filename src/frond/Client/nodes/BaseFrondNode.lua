--[=[
	@class BaseFrondNode

	Base class.
]=]

local require = require(script.Parent.loader).load(script)

local BaseObject = require("BaseObject")
local GoodSignal = require("GoodSignal")
local FrondConstants = require("FrondConstants")
local FrondUtils = require("FrondUtils")
local Observable = require("Observable")
local Brio = require("Brio")
local Maid = require("Maid")
local ValueObject = require("ValueObject")
local RxBrioUtils = require("RxBrioUtils")

local BaseFrondNode = setmetatable({}, BaseObject)
BaseFrondNode.ClassName = "BaseFrondNode"
BaseFrondNode.__index = BaseFrondNode

function BaseFrondNode.new()
	local self = setmetatable(BaseObject.new(), BaseFrondNode)

	self._onMeasureCallback = nil
	self._onLayoutCallback = nil

	self.SizeUpdated = GoodSignal.new()
	self._maid:GiveTask(self.SizeUpdated)

	self.PositionUpdated = GoodSignal.new()
	self._maid:GiveTask(self.PositionUpdated)

	self._parentValue = ValueObject.new(nil)
	self._maid:GiveTask(self._parentValue)

	-- Children.
	self.ChildAdded = GoodSignal.new()
	self._maid:GiveTask(self.ChildAdded)

	self.ChildRemoved = GoodSignal.new()
	self._maid:GiveTask(self.ChildRemoved)

	self._children = {}

	-- Start needing re-layouting.
	self._dirtyFlag = true

	-- Default transform.
	self._transform = Vector3.zero

	-- Sizing default.
	self._xSizingMode = FrondConstants.SIZING_UNSET
	self._ySizingMode = FrondConstants.SIZING_UNSET

	self._aspectRatio = 0

	return self
end

function BaseFrondNode:ObserveSizeUDim2()
	return Observable.new(function(sub)
		local lX, lY

		local function update()
			if self._sizeX ~= lX or self._sizeY ~= lY then
				sub:Fire(UDim2.fromOffset(self._sizeX, self._sizeY))
			end
		end

		update()
		return self.SizeUpdated:Connect(update)
	end)
end

function BaseFrondNode:ObservePositionUDim2()
	return Observable.new(function(sub)
		local lX, lY

		local function update()
			if self._posX ~= lX or self._posY ~= lY then
				sub:Fire(UDim2.fromOffset(self._posX, self._posY))
			end
		end

		update()
		return self.PositionUpdated:Connect(update)
	end)
end

function BaseFrondNode:ObserveChildrenBrio()
	return Observable.new(function(sub)
		local maid = Maid.new()

		local function childAdded(child)
			local brio = Brio.new(child)
			maid[child] = brio
			sub:Fire(brio)
		end

		local function childRemoved(child)
			maid[child] = nil
		end

		maid:GiveTask(self.ChildAdded:Connect(childAdded))
		maid:GiveTask(self.ChildRemoved:Connect(childRemoved))
		for _, child in self:GetChildren() do
			childAdded(child)
		end

		return maid
	end)
end

function BaseFrondNode:_addThisAsChild(child)
	self:_markDirty()
	table.insert(self._children, child)
	self.ChildAdded:Fire(child)

	return function()
		-- TODO: Could get really slow if we're removing lots of elements?!
		table.remove(self._children, table.find(self._children, child))
		self.ChildRemoved:Fire(child)
	end
end

function BaseFrondNode:SetParent(parentNode)
	-- When using this framework, parent nodes should be added to a maid last.
	-- This tearing down the tree from the bottom-up.
	-- Therefore, child elements should be 'own' the connection to their parent.
	self._parentValue.Value = parentNode
	self._maid._parentConn = parentNode:_addThisAsChild(self)

	self:_markDirty()

	return function()
		self._parentValue.Value = nil
		self._maid._parentConn = nil
	end
end

function BaseFrondNode:GetParent()
	return self._parentValue.Value
end

function BaseFrondNode:ObserveParentBrio()
	return self._parentValue:Observe():Pipe({
		RxBrioUtils.switchToBrio(),
		RxBrioUtils.where(function(value)
			return value ~= nil
		end),
	})
end

-- Returns how big the view wants to be.
-- https://developer.android.com/reference/android/view/View#measure(int,%20int).
-- Do *not* override! Set a callback.
function BaseFrondNode:Measure(widthMeasureSpec: number, heightMeasureSpec: number): (number, number)
	-- If we're not dirty, don't bother re-sizing.
	if not self._dirtyFlag then
		return self._measureX, self._measureY
	end

	-- Should be slightly faster than indexing ourselves...
	local x, y

	if self._onMeasureCallback then
		x, y = self:_onMeasureCallback(widthMeasureSpec, heightMeasureSpec)
	else
		x, y = self:_defaultMeasure(widthMeasureSpec, heightMeasureSpec)
	end

	-- Cache for later use.
	self._measureX, self._measureY = x, y

	return x, y
end

-- Measure the frond based purely on its parent. No contents or anything.
function BaseFrondNode:_defaultMeasure(widthMeasureSpec: number, heightMeasureSpec: number): (number, number)
	local x, y =
		FrondUtils.evaluateConstraint(widthMeasureSpec, self._xSizingMode, self._xSizingValue),
		FrondUtils.evaluateConstraint(heightMeasureSpec, self._ySizingMode, self._ySizingValue)
	if self._aspectRatio ~= 0 then
		-- Our dominant axis will be the length set explicitly.
		-- TODO: What if both axes have definite sizing? Pick one?
		if self._xSizingMode == FrondConstants.SIZING_UNSET then
			x = self._aspectRatio * y
		elseif self._ySizingMode == FrondConstants.SIZING_UNSET then
			y = self._aspectRatio * x
		end
	end
	return x, y
end

-- Applies size.
-- https://developer.android.com/reference/android/view/View#layout(int,%20int,%20int,%20int).
-- Do *not* override! Set a callback.
function BaseFrondNode:Layout(l: number, t: number, r: number, b: number): nil
	-- TODO: Can't use dirty flag, as *all* elements are weakly positioned!
	-- TODO: Block layout update if positions are equal!
	-- TODO: Is it faster to update position vs size first? Can we do both at once?

	-- Position update.
	local posUpdated = self._posX ~= l or self._posY ~= t
	if posUpdated then
		self._posX, self._posY = l, t
		self.PositionUpdated:Fire()
	end

	-- Size update.
	local sizeX, sizeY = r - l, b - t
	local sizeUpdated = self._sizeX ~= sizeX or self._sizeY ~= sizeY
	if sizeUpdated then
		self._sizeX, self._sizeY = sizeX, sizeY
		self.SizeUpdated:Fire()
	end

	-- Without layout callback just void. It doesn't return.
	if self._onLayoutCallback and (self._dirtyFlag or sizeUpdated) then
		self:_onLayoutCallback(l, t, r, b)
	end
end

function BaseFrondNode:SetSizingXY(mode, value)
	self._xSizingMode = mode
	self._xSizingValue = value
	self._ySizingMode = mode
	self._ySizingValue = value
	self:_markDirty()
end

function BaseFrondNode:SetSizingX(mode, value)
	self._xSizingMode = mode
	self._xSizingValue = value
	self:_markDirty()
end

function BaseFrondNode:SetSizingY(mode, value)
	self._ySizingMode = mode
	self._ySizingValue = value
	self:_markDirty()
end

function BaseFrondNode:SetGhost(ghost: boolean)
	self._ghost = ghost
	self:_markDirty()
end

function BaseFrondNode:SetTransform(transform)
	self._transform = transform
	self:_markDirty()
end

function BaseFrondNode:SetAspectRatio(aspectRatio: number)
	self._aspectRatio = aspectRatio
	self:_markDirty()
end

-- Element has unset size. So its size *should* contribute... but we don't know it yet!
function BaseFrondNode:HasUnsetEdge()
	return self._xSizingMode == FrondConstants.SIZING_UNSET or self._ySizingMode == FrondConstants.SIZING_UNSET
end

-- Element has a fixed size, which might sibling elements around.
function BaseFrondNode:HasFixedEdge()
	return self._xSizingMode == FrondConstants.SIZING_PIXEL or self._ySizingMode == FrondConstants.SIZING_PIXEL
end

-- Returns whether the node has a % sized edge, i.e. dependent on other elements in some way.
-- Though note that this will never push other elements around, nor affect the size of the parent.
function BaseFrondNode:HasScaledEdge()
	return self._xSizingMode == FrondConstants.SIZING_SCALE or self._ySizingMode == FrondConstants.SIZING_SCALE
end

function BaseFrondNode:_recursiveMarkClean()
	for _, child in self:GetChildren() do
		if child._dirtyFlag then
			child:_recursiveMarkClean()
		end
	end

	self._dirtyFlag = false
end

function BaseFrondNode:_markDirty()
	-- TODO: This could be called on a destructed node. That would be really bad!
	if not self._dirtyFlag then
		self._dirtyFlag = true

		-- TODO: Only need to update the parent if we're going to change its size!

		if self:GetParent() then
			self:GetParent():_markDirty()
		end
	end
end

function BaseFrondNode:ComputeLayout(maxX: number, maxY: number)
	assert(typeof(maxX) == "number", "Bad maxX")
	assert(typeof(maxY) == "number", "Bad maxY")

	-- TODO: Benchmark.
	if not self._dirtyFlag then
		return
	end

	-- Recursive layout + update.
	self:Measure(maxX, maxY)
	self:Layout(0, 0, self._measureX, self._measureY)

	-- Mark all clean again :).
	self:_recursiveMarkClean()
end

function BaseFrondNode:GetChildren()
	return self._children
end

return BaseFrondNode
