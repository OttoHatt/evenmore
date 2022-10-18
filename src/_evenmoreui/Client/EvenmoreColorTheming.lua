--[=[
	@class EvenmoreColorTheming
	@ignore

	Color themes for util UI.
]=]

local require = require(script.Parent.loader).load(script)

local RunService = game:GetService("RunService")

local Blend = require("Blend")
local ColorGradeUtils = require("ColorGradeUtils")
local Rx = require("Rx")
local ValueObject = require("ValueObject")
local ValueObjectUtils = require("ValueObjectUtils")

local LIGHT_THEME = table.freeze({
	Glyph = Color3.fromHex("#4A382E"),
	Grey = Color3.fromHex("#606058"),
	LightGrey = Color3.fromHex("#B1B0AC"),
	Neutral = Color3.fromHex("#F7F3E7"),
	OrangeRed = Color3.fromHex("#FEA154"),
	Red = Color3.fromHex("#F26B6B"),
})

local EvenmoreColorTheming = {}

function EvenmoreColorTheming:Init()
	assert(not self._initialized, "Already initialized")
	self._initialized = true

	self._currentTheme = ValueObject.new(LIGHT_THEME)
end

function EvenmoreColorTheming:_verifyInit()
	if not RunService:IsRunning() and not self._initialized then
		-- Initialize for Hoarcekat!
		self:Init()
	end

	assert(self._initialized, "Not initialized!")
end

local function deriveColor3(value: Color3, shade: number?, vividness: number?)
	if shade then
		return ColorGradeUtils.getGradedColor(value, shade, vividness)
	else
		return value
	end
end

--[=[
	Observe a color value from the current theme, with optional modifiers.

	@private
	@param colorName string
	@param shade number? | Observable<number?>
	@param vividness number? | Observable<number?>
	@return Observable<Color3>
]=]
function EvenmoreColorTheming:ObserveColor(colorName, shade, vividness)
	assert(typeof(colorName) == "string", "Bad colorName")

	self:_verifyInit()

	return self:_observeValue(colorName):Pipe({
		Rx.switchMap(function(value: Color3)
			return Blend.Computed(value, shade, vividness, deriveColor3)
		end),
	})
end

function EvenmoreColorTheming:_observeValue(colorName: string)
	return Blend.Computed(self:_observeTheme(), function(theme)
		return theme[colorName]
	end)
end

function EvenmoreColorTheming:_observeTheme()
	return ValueObjectUtils.observeValue(self._currentTheme)
end

function EvenmoreColorTheming:Destroy()
	self._currentTheme:Destroy()
end

return EvenmoreColorTheming
