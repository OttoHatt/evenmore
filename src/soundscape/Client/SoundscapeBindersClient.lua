--[=[
	@class SoundscapeBindersClient
	@client
]=]

local require = require(script.Parent.loader).load(script)

local BinderProvider = require("BinderProvider")
local Binder = require("Binder")

return BinderProvider.new(script.Name, function(self, serviceBag)
--[=[
	@prop SoundscapeTrigger Binder<SoundscapeTrigger>
	@within SoundscapeBindersClient
]=]
	self:Add(Binder.new("SoundscapeTrigger", require("SoundscapeTrigger"), serviceBag))
end)