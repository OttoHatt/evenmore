--[=[
	@class EvenmoreColorTheming
	@ignore

	Color themes for util UI.
]=]

local require = require(script.Parent.loader).load(script)

local RunService = game:GetService("RunService")

local Blend = require("Blend")
local ColorGradeUtils = require("ColorGradeUtils")
local ValueObject = require("ValueObject")
local ValueObjectUtils = require("ValueObjectUtils")
local Maid = require("Maid")
local Observable = require("Observable")
local Rx = require("Rx")

local LIGHT_THEME = table.freeze({
	Glyph = Color3.fromHex("#171717"),
	Neutral = Color3.fromHex("#f5f5f5"),
	Primary = Color3.fromHex("#2563eb"),
})
local DARK_THEME = table.freeze({
	Glyph = Color3.fromHex("#ffffff"),
	Neutral = Color3.fromHex("#404040"),
	Primary = Color3.fromHex("#3b82f6"),
})

local EvenmoreColorTheming = {}

local function observeStudioTheme()
	return Observable.new(function(sub)
		local studio: Studio = settings().Studio

		local function update()
			if studio.Theme then
				-- For some reason this can sometimes be nil?????
				sub:Fire(studio.Theme)
			end
		end

		update()
		return studio.ThemeChanged:Connect(update)
	end)
end

function EvenmoreColorTheming:Init()
	assert(not self._initialized, "Already initialized")
	self._initialized = true

	self._maid = Maid.new()

	self._currentTheme = ValueObject.fromObservable(observeStudioTheme():Pipe({
		Rx.map(function(theme: StudioTheme)
			-- Completely guess.
			-- If the main pane color is quite dark, then we'll be displaying on a dark background in Hoarcekat / studio.
			-- Therefore, pick some dark colours.
			-- We should probably just pick colors from studio, but this way we get some neat customisation.
			local mainColor = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground, Enum.StudioStyleGuideModifier.Default)
			local grade = ColorGradeUtils.getGrade(mainColor)
			return if grade > 50 then DARK_THEME else LIGHT_THEME
		end)
	}))
	self._maid:GiveTask(self._currentTheme)
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
	self._maid:DoCleaning()
end

return EvenmoreColorTheming
