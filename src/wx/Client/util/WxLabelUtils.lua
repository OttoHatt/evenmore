--[=[
	@class WxLabelUtils

	Utils for working with WxLabels.
]=]

local require = require(script.Parent.loader).load(script)

local WxLabel = require("WxLabel")
local WxTheme = require("WxTheme")

local WxLabelUtils = {}

function WxLabelUtils.makeFromDefinition(definition)
	local label = WxLabel.new()
	label:SetFont(definition.Font or Enum.Font.FredokaOne)
	label:SetSize(definition.Size or 24)
	label:SetLineHeight(definition.LineHeight or 1)
	label:SetTransparency(definition.Transparency or 0)
	label:SetColor(definition.Color or Color3.new(0, 0, 0))
	label:SetWeight(definition.Weight)
	return label
end

function WxLabelUtils.makeTitleLabel()
	return WxLabelUtils.makeFromDefinition(WxTheme.TEXT_STYLE_TITLE)
end

function WxLabelUtils.makeSubTitleLabel()
	return WxLabelUtils.makeFromDefinition(WxTheme.TEXT_STYLE_SUBTITLE)
end

function WxLabelUtils.makeBodyLabel()
	return WxLabelUtils.makeFromDefinition(WxTheme.TEXT_STYLE_BODY)
end

function WxLabelUtils.makeActionLabel()
	return WxLabelUtils.makeFromDefinition(WxTheme.TEXT_STYLE_ACTION)
end

return WxLabelUtils
