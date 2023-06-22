local require = require(script.Parent.loader).load(script)

local RefCountedLut = require("RefCountedLut")
local FlexFrondNode = require("FlexFrondNode")

local globalFrondLut = RefCountedLut.new(function()
	return FlexFrondNode.new()
end)

return globalFrondLut