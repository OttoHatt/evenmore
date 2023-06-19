--[=[
	@class FrondAttributeUtils

	Utils for working with frond-bound instance attributes.
]=]

local require = require(script.Parent.loader).load(script)

-- Uniquely identify which attributes belong to fronding.
local FROND_ATTRIBUTE_PREFIX = "Frond_"

local Blend = require("Blend")
local Observable = require("Observable")
local Rx = require("Rx")
local String = require("String")

local FrondAttributeUtils = {}

-- To be used with Blend.
function FrondAttributeUtils.makeAttributeFactory(attributeName: string)
	assert(typeof(attributeName) == "string", "Bad attributeName")

	-- Ugly caching, this is a somewhat hot function.
	local bakedAttributeName: string = FROND_ATTRIBUTE_PREFIX .. attributeName

	return function(parent: Instance, content)
		assert(typeof(parent) == "Instance", "Bad parent")

		-- TODO: Typecheck 'content'. Could be an observable/primitive of number, Vector2, Vector3, etc.
		-- Hackily set the attribute and reflect it to our virtual frond DOM.
		-- We use an observable as function keys are passed to 'Blend.toEventObservable'.
		local propertyObservable = Blend.toPropertyObservable(content)
		if propertyObservable then
			return Observable.new(function()
				return propertyObservable:Subscribe(function(value: any?)
					parent:SetAttribute(bakedAttributeName, value)
				end)
			end)
		else
			-- Let's just hope this is a primitive, serializable type..!
			parent:SetAttribute(bakedAttributeName, content)
			return Rx.EMPTY
		end
	end
end

function FrondAttributeUtils.isFrondAttribute(attributeName: string): boolean
	return String.startsWith(attributeName, FROND_ATTRIBUTE_PREFIX)
end

function FrondAttributeUtils.parseFrondAttributeName(codedName: string): string?
	local attributeName: string = String.removePrefix(codedName, FROND_ATTRIBUTE_PREFIX)
	if attributeName == codedName then
		-- We didn't strip anyting, so the string doesn't have the prefix.
		-- Therefore we don't care for this attribute.
		return nil
	else
		return attributeName
	end
end

return FrondAttributeUtils
