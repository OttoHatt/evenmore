--[=[
	@class GridFondNode

	Grid type node.
]=]

local require = require(script.Parent.loader).load(script)

local BaseFrondNode = require("BaseFrondNode")

local GridFondNode = setmetatable({}, BaseFrondNode)
GridFondNode.ClassName = "GridFondNode"
GridFondNode.__index = GridFondNode

function GridFondNode.new(obj)
	local self = setmetatable(BaseFrondNode.new(obj), GridFondNode)

	self._elementsPerRow = 3
	self._elementPadding = 0

	return self
end

function GridFondNode:SetElementsPerRow(count: number)
	self._elementsPerRow = count
	self:_markDirty()
end

function GridFondNode:SetElementPadding(padding: number)
	self._elementPadding = padding
	self:_markDirty()
end

local function getCellLength(width: number, p: number, n: number)
	return (width - (n - 1) * p) / n
end

function GridFondNode:_onMeasureCallback(widthMeasureSpec: number, heightMeasureSpec: number): (number, number)
	local defaultX, defaultY = self:_defaultMeasure(widthMeasureSpec, heightMeasureSpec)

	-- All subsequent logic lays out children. We can simply ignore it.
	if #self:GetChildren() == 0 then
		return defaultX, defaultY
	end

	-- TODO: Re-order arguments.
	local cellLength = getCellLength(defaultX, self._elementPadding, self._elementsPerRow)

	for _, child in self:GetChildren() do
		child:Measure(cellLength, cellLength)
	end

	local rowCount = math.ceil(#self:GetChildren() / self._elementsPerRow)
	return defaultX, math.max(defaultY, rowCount * cellLength + (rowCount - 1) * self._elementPadding)
end

function GridFondNode:_onLayoutCallback(l: number, _t: number, r: number, _b: number): nil
	if #self:GetChildren() == 0 then
		return
	end

	local cellLength = getCellLength(r - l, self._elementPadding, self._elementsPerRow)

	local offsetX, offsetY = 0, 0

	for i, child in self:GetChildren() do
		child:Layout(offsetX, offsetY, offsetX + child._measureX, offsetY + child._measureY)

		if i % self._elementsPerRow == 0 then
			-- Wrap rows!
			offsetX = 0
			offsetY += cellLength
			offsetY += self._elementPadding
		else
			-- Gap between elements in a row.
			offsetX += cellLength
			offsetX += self._elementPadding
		end
	end
end

return GridFondNode
