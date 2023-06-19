local require = require(script.Parent.loader).load(script)

local Table = require("Table")

return Table.deepReadonly({
	-- List of nice-looking, generic-ish fonts that you can use everywhere in a UI.
	-- Functions accepting these types must be polymorphic.
	-- https://create.roblox.com/docs/reference/engine/datatypes/Font.
	FONT_INTER = 12187365364,
	FONT_TEKO = 12187376174,
	FONT_KANIT = 12187373592,
	FONT_PROMPT = 12187607287,
	FONT_MULISH = 12187372629,
	FONT_CAIRO = 12187377099,
	FONT_MPLUS = 12188570269,
	FONT_FREDOKA_ONE = "rbxasset://fonts/families/FredokaOne.json",
	FONT_NUNITO = "rbxasset://fonts/families/Nunito.json",
	FONT_SARPANCH = "rbxasset://fonts/families/Sarpanch.json",
	FONT_GOTHAM = "rbxasset://fonts/families/GothamSSm.json",
})