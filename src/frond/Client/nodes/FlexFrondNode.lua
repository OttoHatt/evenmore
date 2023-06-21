--[=[
	@class FlexFrondNode

	Flex frond node.
]=]

local require = require(script.Parent.loader).load(script)

local BaseFrondNode = require("BaseFrondNode")
local FrondConstants = require("FrondConstants")
local FrondUtils = require("FrondUtils")

local FlexFrondNode = setmetatable({}, BaseFrondNode)
FlexFrondNode.ClassName = "FlexFrondNode"
FlexFrondNode.__index = FlexFrondNode

function FlexFrondNode.new(obj)
	local self = setmetatable(BaseFrondNode.new(obj), FlexFrondNode)

	self._paddingL, self._paddingT, self._paddingR, self._paddingB = 0, 0, 0, 0
	self._gap = 0

	self._flowDirection = FrondConstants.DIRECTION_ROW

	self._justifyContentMode = FrondConstants.JUSTIFY_START
	self._alignItemsMode = FrondConstants.ALIGN_START

	return self
end

function FlexFrondNode:SetFlowDirection(direction)
	assert(FrondUtils.isFlowDirection(direction), "Bad direction")
	self._flowDirection = direction
	self:_markDirty()
end

--[=[
    Set gap between elements.

    @padding number
]=]
function FlexFrondNode:SetGap(padding: number)
	self._gap = padding
	self:_markDirty()
end

--[=[
    Set padding on all 4 axis at once.

    @l number
    @t number
    @r number
    @b number
]=]
function FlexFrondNode:SetPadding(l: number, t: number, r: number, b: number)
	self._paddingL, self._paddingT, self._paddingR, self._paddingB = l, t, r, b
	self:_markDirty()
end

--[=[
    Set padding on the X axis (top and bottom).

    @value number
]=]
function FlexFrondNode:SetPaddingX(value: number)
	self._paddingL, self._paddingR = value, value
	self:_markDirty()
end

--[=[
    Set padding on the Y axis (left and right).

    @value number
]=]
function FlexFrondNode:SetPaddingY(value: number)
	self._paddingT, self._paddingB = value, value
	self:_markDirty()
end

--[=[
    Set padding on all edges.

    @value number
]=]
function FlexFrondNode:SetPaddingXY(value: number)
	self._paddingL, self._paddingT, self._paddingR, self._paddingB = value, value, value, value
	self:_markDirty()
end

function FlexFrondNode:SetJustifyContent(mode)
	self._justifyContentMode = mode
	self:_markDirty()
end

function FlexFrondNode:SetAlignItems(mode)
	self._alignItemsMode = mode
	self:_markDirty()
end

function FlexFrondNode:_onMeasureCallback(widthMeasureSpec: number, heightMeasureSpec: number): (number, number)
	local defaultX, defaultY = self:_defaultMeasure(widthMeasureSpec, heightMeasureSpec)

	-- We're dependant on our children's sizing, but we dont' have any children..?
	-- We'll end up with at least one edge of 0 length.
	if #self:GetChildren() == 0 then
		return defaultX, defaultY
	end

	local paddingX = self._paddingL + self._paddingR
	local paddingY = self._paddingT + self._paddingB

	local cX, cY = FrondUtils.measureChildrenBounds(
		self:GetChildren(),
		math.max(0, defaultX - paddingX),
		math.max(0, defaultY - paddingY),
		self._flowDirection,
		self._gap
	)
	self._contentBoundsX, self._contentBoundsY = cX, cY

	-- Will this element respond in size to its children? Only if an edge is unkown!
	if not self:HasUnsetEdge() then
		return defaultX, defaultY
	else
		return cX + paddingX, cY + paddingY
	end
end

function FlexFrondNode:_onLayoutCallback(l: number, t: number, r: number, b: number): nil
	-- All subsequent logic lays out children. We can simply ignore it.
	if #self:GetChildren() == 0 then
		return
	end

	-- This is *without* padding included.
	local containerX, containerY = r - l, b - t
	local containerF, containerC = FrondUtils.toFlowSpace(self._flowDirection, containerX, containerY)

	-- For the cross axis, pick the largest of all elements.
	-- TODO: We can't stretch on the flow axis right? That would be weird...
	-- TODO: Should probably passively re-measure, only now using the applied size of *this* frond node as the bounds.
	local boundsF, boundsC = FrondUtils.toFlowSpace(self._flowDirection, self._contentBoundsX, self._contentBoundsY)

	-- Padding shared for all elements.
	local paddingX1, paddingY1 = self._paddingL, self._paddingT
	local paddingX2, paddingY2 = self._paddingR, self._paddingB
	local paddingF1, paddingC1 = FrondUtils.toFlowSpace(self._flowDirection, paddingX1, paddingY1)
	local paddingF2, paddingC2 = FrondUtils.toFlowSpace(self._flowDirection, paddingX2, paddingY2)

	-- Shared between laying out elements, so we can shift things on the page.
	local trackF: number
	if self._justifyContentMode == FrondConstants.JUSTIFY_START then
		trackF = paddingF1
	elseif self._justifyContentMode == FrondConstants.JUSTIFY_CENTER then
		trackF = paddingF1 + (containerF - paddingF1 - paddingF2) / 2 - boundsF / 2
	elseif self._justifyContentMode == FrondConstants.JUSTIFY_END then
		trackF = containerF - paddingF2 - boundsF
	end

	-- Anchor point positioning.
	local anchorC: number = 0
	if self._alignItemsMode == FrondConstants.ALIGN_START then
		anchorC = 0
	elseif self._alignItemsMode == FrondConstants.ALIGN_CENTER then
		anchorC = 0.5
	elseif self._justifyContentMode == FrondConstants.ALIGN_END then
		anchorC = 1
	end

	for _, child in self:GetChildren() do
		-- Child measurements.
		local sizeF, sizeC
		do
			-- TODO: Nasty hack where we stretch the default position for % width elements...
			-- TODO: How does this line up with the flexbox standard? Presumeably this is wrong...
			-- TODO: Recomputing doesn't resize the container??
			local measureX, measureY = child._measureX, child._measureY
			if
				child._xSizingMode == FrondConstants.SIZING_SCALE
				or child._ySizingMode == FrondConstants.SIZING_SCALE
			then
				measureX, measureY =
					child:_defaultMeasure(containerX - paddingX1 - paddingX2, containerY - paddingY1 - paddingY2)
			end
			sizeF, sizeC = FrondUtils.toFlowSpace(self._flowDirection, measureX, measureY)
			if self._alignItemsMode == FrondConstants.ALIGN_STRETCH then
				sizeC = boundsC
			end
		end
		-- Child offset on cross-axis.
		local offsetC = paddingC1 + -anchorC * sizeC + (containerC - paddingC1 - paddingC2) * anchorC
		-- Combine and move.
		do
			local offX, offY = FrondUtils.toPixelSpace(self._flowDirection, trackF, offsetC)
			offX += child._transform.X
			offY += child._transform.Y

			local sizeX, sizeY = FrondUtils.toPixelSpace(self._flowDirection, sizeF, sizeC)
			child:Layout(offX, offY, offX + sizeX, offY + sizeY)
		end
		-- Ghost elements don't push others around on the page.
		if not child._ghost then
			trackF += sizeF + self._gap
		end
	end
end

return FlexFrondNode
