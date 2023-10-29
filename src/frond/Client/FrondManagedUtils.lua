--[=[
	@class FrondManagedUtils

	Utils for managed fronds.
]=]

local require = require(script.Parent.loader).load(script)

local FlexFrondNode = require("FlexFrondNode")
local FrondConstants = require("FrondConstants")
local RxInstanceUtils = require("RxInstanceUtils")

local FrondManagedUtils = {}

function FrondManagedUtils.mountFrond(instance: GuiBase)
	-- TODO: 'AbsoluteSize' is delayed a frame, which is just causing pain...
	local frond = FlexFrondNode.new()
	frond._maid:GiveTask(
		RxInstanceUtils.observeProperty(instance, "AbsoluteSize"):Subscribe(function(absoluteSize: Vector2)
			frond:SetSizingX(FrondConstants.SIZING_PIXEL, absoluteSize.X)
			frond:SetSizingY(FrondConstants.SIZING_PIXEL, absoluteSize.Y)
		end)
	)
	return frond
end

function FrondManagedUtils.mountFrondCentre()

end

return FrondManagedUtils
