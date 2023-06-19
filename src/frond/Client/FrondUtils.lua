local RunService = game:GetService("RunService")
--[=[
	@class FrondUtils

	Utils for working with fronds and their internal constraints.
]=]

local require = require(script.Parent.loader).load(script)

local FrondConstants = require("FrondConstants")
local Blend = require("Blend")
local RxBrioUtils = require("RxBrioUtils")
local RxValueBaseUtils = require("RxValueBaseUtils")
local Rx = require("Rx")

local FrondUtils = {}

function FrondUtils.isFlowDirection(direction)
	return FrondConstants.DIRECTION_ROW == direction or FrondConstants.DIRECTION_COLUMN == direction
end

-- Return the axis parallel to the flow direction.
function FrondUtils.onFlowAxis(flowDirection, x: number, y: number)
	return if flowDirection == FrondConstants.DIRECTION_ROW then x else y
end

-- Return the axis perpendicular to the flow direction.
function FrondUtils.onCrossAxis(flowDirection, x: number, y: number)
	return if flowDirection == FrondConstants.DIRECTION_ROW then y else x
end

-- Back to pixel space.
function FrondUtils.onXAxis(flowDirection, flow: number, cross: number)
	return if flowDirection == FrondConstants.DIRECTION_ROW then flow else cross
end

-- Back to pixel space.
function FrondUtils.onYAxis(flowDirection, flow: number, cross: number)
	return if flowDirection == FrondConstants.DIRECTION_ROW then cross else flow
end

function FrondUtils.toFlowSpace(flowDirection, x: number, y: number)
	if flowDirection == FrondConstants.DIRECTION_ROW then
		return x, y
	else
		return y, x
	end
end

function FrondUtils.toPixelSpace(flowDirection, flow: number, cross: number)
	if flowDirection == FrondConstants.DIRECTION_ROW then
		return flow, cross
	else
		return cross, flow
	end
end

function FrondUtils.evaluateConstraint(constraint: number, mode, value)
	if mode == FrondConstants.SIZING_PIXEL then
		return value
	elseif mode == FrondConstants.SIZING_SCALE then
		return value * constraint
	else
		return 0
	end
end

function FrondUtils.measureChildrenBounds(
	children: { table },
	maxX: number,
	maxY: number,
	flowDirection,
	elementPadding: number
): (number, number)
	local cF, cC = 0, 0

	local measuringChildren = 0

	for _, child in children do
		local eX, eY = child:Measure(maxX, maxY)

		if not child._ghost then
			measuringChildren += 1

			cF += FrondUtils.onFlowAxis(flowDirection, eX, eY)
			cC = math.max(cC, FrondUtils.onCrossAxis(flowDirection, eX, eY))
		end
	end

	cF += math.max(measuringChildren - 1, 0) * elementPadding

	return FrondUtils.toPixelSpace(flowDirection, cF, cC)
end

function FrondUtils.renderFrondNodeRecursive(node, depth: number?)
	depth = depth or 0

	return Blend.New("Frame")({
		Size = node:ObserveSizeUDim2(),
		Position = node:ObservePositionUDim2(),
		BackgroundColor3 = Color3.fromHSV(0, depth / 7, 1),
		node:ObserveChildrenBrio():Pipe({
			RxBrioUtils.flatMapBrio(function(childNode)
				return FrondUtils.renderFrondNodeRecursive(childNode, depth + 1)
			end),
		}),
	})
end

function FrondUtils.observeAsUDim2(valueBase: Vector3Value)
	return RxValueBaseUtils.observeValue(valueBase):Pipe({
		Rx.map(function(value: Vector3)
			return UDim2.fromOffset(value.X, value.Y)
		end),
	})
end

function FrondUtils.bindComputerPerFrame(frond)
	-- Immediately.
	frond:ComputeLayout()
	-- Then per frame.
	return RunService.RenderStepped:Connect(function()
		frond:ComputeLayout()
	end)
end

return FrondUtils
