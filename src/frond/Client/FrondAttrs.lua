local require = require(script.Parent.loader).load(script)

local FrondConstants = require("FrondConstants")
local Symbol = require("Symbol")
local FrondAttributeUtils = require("FrondAttributeUtils")

local ERR_WRONG_TYPE = Symbol.named("BadPropertyType")

local FrondAttrs = {}

-- Please note, these are declared explicitly for the benefit of your LSP.
-- A metatable lookup thing would be far cuter.

FrondAttrs.Width = function(frond, value: any)
	if typeof(value) == "number" then
		frond:SetSizingX(FrondConstants.SIZING_PIXEL, value)
	else
		return ERR_WRONG_TYPE
	end
end
FrondAttrs.Height = function(frond, value: any)
	if typeof(value) == "number" then
		frond:SetSizingY(FrondConstants.SIZING_PIXEL, value)
	else
		return ERR_WRONG_TYPE
	end
end
FrondAttrs.Padding = function(frond, value: any)
	if typeof(value) == "Vector3" or typeof(value) == "Vector2" then
		frond:SetPaddingX(value.X)
		frond:SetPaddingY(value.Y)
	elseif typeof(value) == "number" then
		frond:SetPaddingX(value)
		frond:SetPaddingY(value)
	elseif typeof(value) == "table" and #value == 4 then
		frond:SetPadding(table.unpack(value))
	else
		return ERR_WRONG_TYPE
	end
end
FrondAttrs.Size = function(frond, value: any)
	if typeof(value) == "Vector3" or typeof(value) == "Vector2" then
		frond:SetSizingX(FrondConstants.SIZING_PIXEL, value.X)
		frond:SetSizingY(FrondConstants.SIZING_PIXEL, value.Y)
	elseif typeof(value) == "number" then
		frond:SetSizingX(FrondConstants.SIZING_PIXEL, value)
		frond:SetSizingY(FrondConstants.SIZING_PIXEL, value)
	elseif typeof(value) == "table" and #value == 2 then
		frond:SetSizingX(value[1])
		frond:SetSizingY(value[2])
	else
		return ERR_WRONG_TYPE
	end
end
FrondAttrs.Gap = function(frond, value: any)
	if typeof(value) == "number" then
		frond:SetGap(value)
	else
		return ERR_WRONG_TYPE
	end
end
FrondAttrs.FlowDirection = function(frond, value: any)
	if value == FrondConstants.DIRECTION_ROW or value == FrondConstants.DIRECTION_COLUMN then
		frond:SetFlowDirection(value)
	else
		return ERR_WRONG_TYPE
	end
end
FrondAttrs.WidthP = function(frond, value: any)
	if typeof(value) == "number" then
		frond:SetSizingX(FrondConstants.SIZING_SCALE, value)
	else
		return ERR_WRONG_TYPE
	end
end
FrondAttrs.HeightP = function(frond, value: any)
	if typeof(value) == "number" then
		frond:SetSizingY(FrondConstants.SIZING_SCALE, value)
	else
		return ERR_WRONG_TYPE
	end
end
FrondAttrs.Ghost = function(frond, value: any)
	if typeof(value) == "boolean" then
		frond:SetGhost(value)
	else
		return ERR_WRONG_TYPE
	end
end
FrondAttrs.Transform = function(frond, value: any)
	if typeof(value) == "Vector3" or typeof(value) == "Vector2" then
		frond:SetTransform(value)
	else
		return ERR_WRONG_TYPE
	end
end
FrondAttrs.JustifyContent = function(frond, value: any)
	if
		value == FrondConstants.JUSTIFY_START
		or value == FrondConstants.JUSTIFY_CENTER
		or value == FrondConstants.JUSTIFY_END
	then
		frond:SetJustifyContent(value)
	else
		return ERR_WRONG_TYPE
	end
end
FrondAttrs.AlignItems = function(frond, value: any)
	if
		value == FrondConstants.ALIGN_START
		or value == FrondConstants.ALIGN_CENTER
		or value == FrondConstants.ALIGN_END
		or value == FrondConstants.ALIGN_STRETCH
	then
		frond:SetAlignItems(value)
	else
		return ERR_WRONG_TYPE
	end
end
FrondAttrs.AspectRatio = function(frond, value: any)
	if typeof(value) == "number" then
		frond:SetAspectRatio(value)
	else
		return ERR_WRONG_TYPE
	end
end

local handlers = {}
-- Switch this around in a loop to fake-out the LSP, getting the handlers to autocomplete.
-- TODO: Replace this hacky meta-programming...
for attributeName, handler in FrondAttrs do
	handlers[attributeName] = handler
	FrondAttrs[attributeName] = FrondAttributeUtils.makeAttributeFactory(attributeName)
end
FrondAttrs._handlers = handlers

function FrondAttrs.runHandlerCoded(frond, codedName: string, value: any): any
	local attributeName: string? = FrondAttributeUtils.parseFrondAttributeName(codedName)

	if attributeName then
		FrondAttrs.runHandler(frond, attributeName, value)
	end
end

function FrondAttrs.runHandler(frond, attributeName: string, value: any): (table, any) -> any
	assert(typeof(frond) == "table", "Bad frond")
	assert(typeof(attributeName) == "string", "Bad attributeName")
	assert(value ~= nil, "Bad value")

	local handler = FrondAttrs._handlers[attributeName]
	if not handler then
		error(`Bad attributeName '{attributeName}', no handler`)
	end

	-- No return code is a success!
	local returnCode = handler(frond, value)
	-- Otherwise...
	if returnCode ~= nil then
		error(`[FrondAttrs] Failed handler for {attributeName} with value '{value}'. Code: '{returnCode}'.`)
	end
end

return FrondAttrs
