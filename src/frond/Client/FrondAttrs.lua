local require = require(script.Parent.loader).load(script)

local Blend = require("Blend")
local Observable = require("Observable")
local String = require("String")
local FrondConstants = require("FrondConstants")

local FrondAttrs = {}
FrondAttrs.FROND_ATTRIBUTE_PREFIX = "Frond_"

-- To be used with Blend.
local function makeAttributeFactory(attributeName: string)
	assert(typeof(attributeName) == "string", "Bad attributeName")

	-- Ugly caching, this is a somewhat hot function.
	local bakedAttributeName: string = FrondAttrs.FROND_ATTRIBUTE_PREFIX .. attributeName

	return function(parent: Instance, content)
		assert(typeof(parent) == "Instance", "Bad parent")

		-- TODO: Typecheck 'content'. Could be an observable/primitive of number, Vector2, Vector3, etc.

		-- Hackily set the attribute and reflect it to our virtual frond DOM.
		-- We use an observable as function keys are passed to 'Blend.toEventObservable'.
		return Observable.new(function()
			local propertyObservable = Blend.toPropertyObservable(content)
			if propertyObservable then
				return propertyObservable:Subscribe(function(value: any?)
					parent:SetAttribute(bakedAttributeName, value)
				end)
			else
				-- Let's just hope this is a primitive, serializable type..!
				parent:SetAttribute(bakedAttributeName, content)
			end
		end)
	end
end

-- Define these explicitly for the beneift of the LSP.
-- This is stupid, really! We should use a loop over some list of valid properties...
FrondAttrs.Width = makeAttributeFactory("Width")
FrondAttrs.Height = makeAttributeFactory("Height")
FrondAttrs.Flow = makeAttributeFactory("Flow")
FrondAttrs.Padding = makeAttributeFactory("Padding")
FrondAttrs.Size = makeAttributeFactory("Size")
FrondAttrs.ElementPadding = makeAttributeFactory("ElementPadding")
FrondAttrs.AlignFlow = makeAttributeFactory("AlignFlow")
FrondAttrs.AlignCrossFlow = makeAttributeFactory("AlignCrossFlow")
FrondAttrs.FlowDirection = makeAttributeFactory("FlowDirection")
FrondAttrs.WidthP = makeAttributeFactory("WidthP")
FrondAttrs.HeightP = makeAttributeFactory("HeightP")
FrondAttrs.StretchOnCrossAxis = makeAttributeFactory("StretchOnCrossAxis")
FrondAttrs.Ghost = makeAttributeFactory("Ghost")
FrondAttrs.Transform = makeAttributeFactory("Transform")

-- Connect changes in these named attributes back into the frond API.
-- These are separate as fronds should be entirely API agnostic.
function FrondAttrs.applyAttribute(frond, attributeName: string, value: number)
	-- Only handle attributes targeted at fronds.
	local shortName: string = String.removePrefix(attributeName, FrondAttrs.FROND_ATTRIBUTE_PREFIX)
	if shortName == attributeName then
		return
	end

	if shortName == "Width" then
		frond:SetSizingX(FrondConstants.SIZING_PIXEL, value)
	elseif shortName == "Height" then
		frond:SetSizingY(FrondConstants.SIZING_PIXEL, value)
	elseif shortName == "Size" then
		-- Assumes Vector3 or Vector2!
		frond:SetSizingX(FrondConstants.SIZING_PIXEL, value.X)
		frond:SetSizingY(FrondConstants.SIZING_PIXEL, value.Y)
	elseif shortName == "WidthP" then
		frond:SetSizingX(FrondConstants.SIZING_SCALE, value)
	elseif shortName == "HeightP" then
		frond:SetSizingY(FrondConstants.SIZING_SCALE, value)
	elseif shortName == "Padding" then
		if typeof(value) == "Vector3" or typeof(value) == "Vector2" then
			frond:SetPaddingX(value.X)
			frond:SetPaddingY(value.Y)
		elseif typeof(value) == "number" then
			frond:SetPaddingXY(value)
		end
	elseif shortName == "ElementPadding" then
		frond:SetElementPadding(value)
	elseif shortName == "AlignFlow" then
		frond:SetAlignFlow(value)
	elseif shortName == "AlignCrossFlow" then
		frond:SetAlignCrossFlow(value)
	elseif shortName == "FlowDirection" then
		frond:SetFlowDirection(value)
	elseif shortName == "StretchOnCrossAxis" then
		-- Assume boolean.
		frond:SetStretchOnCrossAxis(value)
	elseif shortName == "Ghost" then
		frond:SetGhost(value)
	elseif shortName == "Transform" then
		frond:SetTransform(value)
	end
end

return FrondAttrs
