--[=[
	@class SoundScriptConstants
	@client

	This modules defines the format of SoundScripts, and a few generic templates that you can use in your own games.
	SoundScripts in this module are automatically loaded; simply put the name of one (i.e. `city`) in a tagged trigger to use it.

	If you create a soundscape with this system, consider submitting a PR! This module is most valuable as a portable library of soundscapes.

	Format inspired by the [Source Engine soundscape system](https://developer.valvesoftware.com/wiki/Soundscape).
]=]

--- @type SoundScript { reverb: Enum.ReverbType, layers: {SoundEntry} }
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
	No sounds. No reverb.
	@prop default SoundScript
	@readonly
	@within SoundScriptConstants
]=]
SoundScriptConstants.default = table.freeze({ reverb = Enum.ReverbType.NoReverb })

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
	Birds, wind, tree movement. Subtle, dead reverb.
	@prop park SoundScript
	@readonly
	@within SoundScriptConstants
]=]
SoundScriptConstants.park = table.freeze({
	reverb = Enum.ReverbType.Forest,
	layers = {
		-- Forest ambience 2 (SFX)
		{ id = "rbxassetid://9112781689", loop = true, volume = 1.4 },
		-- Neighborhood Birds 2 (SFX)
		{ id = "rbxassetid://9112835068", loop = true, volume = 1.1 },
	},
})

return table.freeze(SoundScriptConstants)