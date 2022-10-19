--[=[
	@class SoundscapeUtils
	@client

	Utilities for working with soundscape script files.
]=]

local SoundscapeUtils = {}

local random = Random.new()

--[=[
    Evaluates a value defined in a soundscript. Supports defualt values, defined values, and values picked randomly in a range.

    @param value nil | number | table -- Value to evaluate
    @param default number? -- Fallback value
    @return number
]=]
function SoundscapeUtils.ev(value: any, default: number?)
	assert(typeof(default) == "number" or typeof(default) == "nil", "Bad default")

	if typeof(value) == "nil" then
		assert(default, "[SoundscapeServiceClient] Evaluated value is nil, but has no fallback default!")
		return default
	elseif typeof(value) == "number" then
		return value
	elseif typeof(value) == "table" and #value == 2 then
		return random:NextNumber(table.unpack(value))
	else
		assert(false, "[SoundscapeServiceClient] Invalid soundscape property!")
	end
end

return SoundscapeUtils