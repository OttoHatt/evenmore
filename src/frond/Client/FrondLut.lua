local require = require(script.Parent.loader).load(script)

local RefCountedLut = require("RefCountedLut")
local FlexFrondNode = require("FlexFrondNode")

return RefCountedLut.new(FlexFrondNode.new)