--[=[
	@class SoundScriptUtils
	@client

	Utilities for working with soundscape script files.
]=]

local SoundScriptUtils = {}

local RANDOM = Random.new()

--[=[
    Evaluates a value defined in a soundscript. Supports defualt values, defined values, and values picked randomly in a range.

    @param value nil | number | {number} -- Value to evaluate
    @param default number? -- Fallback value
    @return number
]=]
function SoundScriptUtils.ev(value: nil | number | {number}, default: number?)
	assert(typeof(default) == "number" or typeof(default) == "nil", "Bad default")

	if typeof(value) == "nil" then
		assert(default, "[SoundscapeServiceClient] Evaluated value is nil, but has no fallback default!")
		return default
	elseif typeof(value) == "number" then
		return value
	elseif typeof(value) == "table" and #value == 2 then
		return RANDOM:NextNumber(table.unpack(value))
	else
		error("[SoundscapeServiceClient] Invalid soundscape property!")
	end
end

return SoundScriptUtils
