local require = require(script.Parent.loader).load(script)

local WxConstants = require("WxConstants")

return table.freeze({
	TEXT_STYLE_TITLE = {
		Font = WxConstants.FONT_KANIT,
		Size = 48 * 1.2,
		Weight = Enum.FontWeight.SemiBold,
	},
	TEXT_STYLE_BODY = {
		Font = WxConstants.FONT_CAIRO,
		Size = 35,
		LineHeight = 0.7,
		Weight = Enum.FontWeight.SemiBold,
	},
	TEXT_STYLE_ACTION = {
		Font = WxConstants.FONT_KANIT,
		Size = 24,
		LineHeight = 1,
		Weight = Enum.FontWeight.SemiBold,
		Color = Color3.new(1, 1, 1),
	},
})
