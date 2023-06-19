local require = require(script.Parent.loader).load(script)

local Table = require("Table")

local CONSTANTS = {
	-- TODO: Move symbols? This is quite hacky, and there's probably ovearhead in string comparisons...
	SIZING_SCALE = "SizingScale",
	SIZING_PIXEL = "SizingPixel",
	SIZING_UNSET = "SizingUnset",

	DIRECTION_ROW = "DirectionRow",
	DIRECTION_COLUMN = "DirectionColumn",

	-- https://developer.mozilla.org/en-US/docs/Web/CSS/justify-content.
	JUSTIFY_START = "JustifyStart",
	JUSTIFY_CENTER = "JustifyCenter",
	JUSTIFY_END = "JustifyEnd",

	-- https://developer.mozilla.org/en-US/docs/Web/CSS/align-items
	ALIGN_STRETCH = "AlignStretch",
	ALIGN_START = "AlignStart",
	ALIGN_CENTER = "AlignCenter",
	ALIGN_END = "AlignEnd",
}
Table.deepReadonly(CONSTANTS)
return CONSTANTS