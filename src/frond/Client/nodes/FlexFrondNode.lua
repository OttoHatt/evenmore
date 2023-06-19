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

	self._paddingX = 0
	self._paddingY = 0
	self._elementPadding = 0

	self._flowDirection = FrondConstants.DIRECTION_ROW

	self._alignFlowMode = FrondConstants.ALIGN_START
	self._alignCrossFlowMode = FrondConstants.ALIGN_START

	return self
end

function FlexFrondNode:SetFlowDirection(direction)
	assert(FrondUtils.isFlowDirection(direction), "Bad direction")
	self._flowDirection = direction
	self:_markDirty()
end

-- Applied along flow axis.
function FlexFrondNode:SetElementPadding(padding: number)
	self._elementPadding = padding
	self:_markDirty()
end

function FlexFrondNode:SetPaddingXY(value)
	assert(typeof(value) == "number", "Bad value")
	self._paddingX = value
	self._paddingY = value
	self:_markDirty()
end

function FlexFrondNode:SetPaddingX(value)
	assert(typeof(value) == "number", "Bad value")
	self._paddingX = value
	self:_markDirty()
end

function FlexFrondNode:SetPaddingY(value)
	assert(typeof(value) == "number", "Bad value")
	self._paddingY = value
	self:_markDirty()
end

function FlexFrondNode:SetAlignFlow(mode)
	self._alignFlowMode = mode
	self:_markDirty()
end

function FlexFrondNode:SetAlignCrossFlow(mode)
	self._alignCrossFlowMode = mode
	self:_markDirty()
end

function FlexFrondNode:SetStretchOnCrossAxis(stretch: boolean)
	self._stretchOnCrossAxis = stretch
	self:_markDirty()
end

function FlexFrondNode:_onMeasureCallback(widthMeasureSpec: number, heightMeasureSpec: number): (number, number)
	local defaultX, defaultY = self:_defaultMeasure(widthMeasureSpec, heightMeasureSpec)

	-- We're dependant on our children's sizing, but we dont' have any children..?
	-- We'll end up with at least one edge of 0 length.
	if #self:GetChildren() == 0 then
		return defaultX, defaultY
	end

	local paddingX = self._paddingX
	local paddingY = self._paddingY

	local cX, cY = FrondUtils.measureChildrenBounds(
		self:GetChildren(),
		math.max(0, defaultX - paddingX * 2),
		math.max(0, defaultY - paddingY * 2),
		self._flowDirection,
		self._elementPadding
	)
	self._contentBoundsX, self._contentBoundsY = cX, cY

	-- Will this element respond in size to its children? Only if an edge is unkown!
	if not self:HasUnsetEdge() then
		return defaultX, defaultY
	else
		return cX + paddingX * 2, cY + paddingY * 2
	end
end

-- Track aligning on a given align mode axis.
local function alignModeFlow(alignMode, containerS, paddingS, boundsS, trackS)
	if alignMode == FrondConstants.ALIGN_START then
		return paddingS + trackS
	elseif alignMode == FrondConstants.ALIGN_MIDDLE then
		return containerS / 2 - boundsS / 2 + trackS
	elseif alignMode == FrondConstants.ALIGN_END then
		return containerS - paddingS - boundsS + trackS
	end
end
local function alignModeCross(alignMode, containerS, paddingS, boundsS, sizeS)
	if alignMode == FrondConstants.ALIGN_START then
		return paddingS
	elseif alignMode == FrondConstants.ALIGN_MIDDLE then
		return containerS / 2 - boundsS / 2 + (boundsS - sizeS) / 2
	elseif alignMode == FrondConstants.ALIGN_END then
		return containerS - paddingS - boundsS + (boundsS - sizeS)
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

	-- Now, layout elements.
	local trackF, trackC = 0, 0
	local paddingF, paddingC = FrondUtils.toFlowSpace(self._flowDirection, self._paddingX, self._paddingY)

	for _, child in self:GetChildren() do
		-- Child measurements.
		-- TODO: Nasty hack where we stretch the default position for % width elements...
		local sizeF, sizeC
		do
			local measureX, measureY = child._measureX, child._measureY
			if child._xSizingMode == FrondConstants.SIZING_SCALE then
				measureX = (containerX - self._paddingX * 2) * child._xSizingValue
			end
			if child._ySizingMode == FrondConstants.SIZING_SCALE then
				measureY = (containerY - self._paddingY * 2) * child._ySizingValue
			end
			local cMeasureF, cMeasureC = FrondUtils.toFlowSpace(self._flowDirection, measureX, measureY)
			sizeF, sizeC = cMeasureF, if self._stretchOnCrossAxis then boundsC else cMeasureC
		end

		do
			-- Local copy of offsets that we can manipulate.
			local offsetF = alignModeFlow(self._alignFlowMode, containerF, paddingF, boundsF, trackF)
			local offsetC = alignModeCross(self._alignCrossFlowMode, containerC, paddingC, boundsC, sizeC)

			local offX, offY = FrondUtils.toPixelSpace(self._flowDirection, offsetF, offsetC)
			local sizeX, sizeY = FrondUtils.toPixelSpace(self._flowDirection, sizeF, sizeC)

			offX += child._transform.X
			offY += child._transform.Y

			child:Layout(offX, offY, offX + sizeX, offY + sizeY)
		end

		-- Ghost elements don't push overs around on the page.
		if not child._ghost then
			trackF += sizeF + self._elementPadding
			trackC += sizeC
		end
	end
end

return FlexFrondNode
