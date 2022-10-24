--[=[
	@class BaseBarElementUtils
	@ignore
	@client

	Utils for working with BaseBarElements.
]=]

local require = require(script.Parent.loader).load(script)

local Blend = require("Blend")

local BaseBarElementUtils = {}

local SWATCH_WHEN_SELECTED = 40
local SWATCH_WHEN_DESELECTED = 20

function BaseBarElementUtils.observePrimaryColor(colorTheming, isActive)
	return colorTheming:ObserveColor(
		"Primary",
		Blend.Spring(
			Blend.Computed(isActive, function(active)
				return if active then SWATCH_WHEN_SELECTED else SWATCH_WHEN_DESELECTED
			end),
			100
		)
	)
end

return BaseBarElementUtils