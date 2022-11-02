--[=[
	@class SoundScriptConstants
	@client

	This modules defines the format of SoundScripts, and a few generic templates that you can use in your own games.
	SoundScripts in this module are automatically loaded; simply put the name of one (i.e. `city`) in a tagged trigger to use it.

	If you create a SoundScript with this system, please consider submitting a PR!
	This module is most valuable as a library of soundscapes that can be used in a wide variety of games.

	Format inspired by the [Source Engine soundscape system](https://developer.valvesoftware.com/wiki/Soundscape).
]=]

--- @type SoundScript { reverb: Enum.ReverbType, layers: {SoundEntry}, includes: {SoundScript}? }
--- @within SoundScriptConstants

--- @type SoundEntry { id: string, loop: boolean?, volume: SoundValue, pitch: SoundValue, delay: SoundValue }
--- @within SoundScriptConstants

--[=[
	@type SoundValue { number } | number | nil
	@within SoundScriptConstants
	This is a low-level property for a soundscript. These are evaluated each delay a sound is played.

	* A number in -> The same number out
	* A two-long number array in -> A random value within the range of the two
	* A 'nil' in -> a 'nil' out, falling back to a default value (i.e. volume = 1)
]=]

local SoundScriptConstants = {}

--[=[
	Traffic, cars honking, train passing, birds. Echoey reverb like you're between buildings.
	@prop city SoundScript
	@readonly
	@within SoundScriptConstants
]=]
SoundScriptConstants.city = table.freeze({
	reverb = Enum.ReverbType.City,
	layers = {
		-- City ambience 1 (SFX)
		{ id = "rbxassetid://9112758242", loop = true, volume = 1.1 },
		-- Neighborhood Birds 2 (SFX)
		{ id = "rbxassetid://9112835068", loop = true, volume = 1.3 },
		-- Train Running Sound
		{
			id = "rbxassetid://6011714588",
			loop = false,
			volume = 0.2,
			pitch = { 0.8, 1.05 },
			delay = { 50, 80 },
		},
		-- Auto Horns 1 (SFX)
		{
			id = "rbxassetid://9113209418",
			loop = false,
			volume = { 0.07, 0.1 },
			pitch = { 0.97, 1.03 },
			delay = { 30, 40 },
		},
		-- Auto Horns 10 (SFX)
		{
			id = "rbxassetid://9113208403",
			loop = false,
			volume = { 0.07, 0.1 },
			pitch = { 0.97, 1.03 },
			delay = { 35, 50 },
		},
		-- Auto Horns 17 (SFX)
		{
			id = "rbxassetid://9113210592",
			loop = false,
			volume = { 0.07, 0.1 },
			pitch = { 0.97, 1.03 },
			delay = { 35, 50 },
		},
		-- Auto Horns 4 (SFX)
		{
			id = "rbxassetid://9113207813",
			loop = false,
			volume = { 0.07, 0.1 },
			pitch = { 0.97, 1.03 },
			delay = { 25, 50 },
		},
		-- Very very rare creepy scream!
		-- Screaming Tone 3 (SFX)
		{
			id = "rbxassetid://9118841838",
			loop = false,
			volume = 0.3,
			delay = { 60 * 25, 60 * 60 },
		},
	},
})

--[=[
	Random bump noises, echoey reverb. Probably best used as an include for other soundscapes.
	@prop bumps SoundScript
	@readonly
	@within SoundScriptConstants
]=]
SoundScriptConstants.bumps = table.freeze({
	reverb = Enum.ReverbType.Cave,
	includes = {},
	layers = {
		-- Apartment Bumps 1 (SFX)
		{
			id = "rbxassetid://9113135451",
			loop = false,
			volume = { 0.1, 0.2 },
			pitch = { 0.97, 1.03 },
			delay = { 0, 60 * 2 },
		},
		-- Apartment Bumps 3 (SFX)
		{
			id = "rbxassetid://9113136153",
			loop = false,
			volume = { 0.1, 0.2 },
			pitch = { 0.97, 1.03 },
			delay = { 0, 60 * 2 },
		},
		-- Apartment Bumps 4 (SFX)
		{
			id = "rbxassetid://9113135034",
			loop = false,
			volume = { 0.1, 0.2 },
			pitch = { 0.97, 1.03 },
			delay = { 0, 60 * 2 },
		},
	},
})

--[=[
	Air conditioning, light machine noise, electric light hums. Occasional bumping noises from importing [SoundScriptConstants.bumps].
	@prop office SoundScript
	@readonly
	@within SoundScriptConstants
]=]
SoundScriptConstants.office = table.freeze({
	reverb = Enum.ReverbType.CarpettedHallway,
	includes = {
		SoundScriptConstants.bumps,
	},
	layers = {
		-- Bar Sign Buzz 5 (SFX)
		{
			id = "rbxassetid://9113285810",
			loop = false,
			volume = { 1.2, 1.5 },
			pitch = { 0.97, 1.03 },
			delay = { 1, 6 },
		},
		-- Amp Hum Open Input 7 (SFX)
		{
			id = "rbxassetid://9113114288",
			loop = false,
			volume = { 0.05, 0.07 },
			pitch = { 0.97, 1.03 },
			delay = { 13, 20 },
		},
		-- Hum
		{
			id = "rbxassetid://5523254861",
			loop = false,
			volume = { 0.08, 0.15 },
			pitch = { 0.97, 1.03 },
			delay = { 13, 20 },
		},
		-- Air Conditioner Sound offical
		{
			id = "rbxassetid://6014202040",
			loop = true,
			volume = 0.55,
			pitch = 1,
		},
		-- Machine Room 4 (SFX)
		{
			id = "rbxassetid://9112825229",
			loop = true,
			pitch = 1.55,
			volume = 2,
		},
		-- Supermarket Activity Moving Items Along Cabi (SFX)
		{
			id = "rbxassetid://9126010508",
			loop = false,
			volume = { 0.1, 0.15 },
			pitch = { 0.97, 1.03 },
			delay = { 13, 45 },
		},
		-- Dream Room Analog Synth Glisses Eerie Harmon (SFX)
		-- {
		-- 	id = "rbxassetid://9125499063",
		-- 	loop = true,
		-- 	volume = .05,
		-- 	pitch = 2,
		-- },
	},
})

return table.freeze(SoundScriptConstants)
