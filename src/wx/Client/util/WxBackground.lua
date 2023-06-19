--[=[
	@class WxBackground

	Generate a polymorphic background / gradient thing.
]=]

local require = require(script.Parent.loader).load(script)

local Blend = require("Blend")
local Observable = require("Observable")
local Maid = require("Maid")

local WxBackground = {}

function WxBackground.Polymorphic(parent, topValue)
	return Observable.new(function(_sub)
		local maid = Maid.new()

		-- TODO: Fire observable?
		local function ensureGradient(): UIGradient
			if maid._gradient then
				return
			end

			maid._gradient = Instance.new("UIGradient")
			maid._gradient.Rotation = 90
			maid._gradient.Parent = parent
		end

		maid:GiveTask(
			Blend.toPropertyObservable(topValue):Subscribe(function(value: { Color3 } | ColorSequence | Color3 | nil)
				if typeof(value) == "table" then
					parent.BackgroundColor3 = Color3.new(1, 1, 1)

					-- TODO: Support >2 colors!
					if #value == 2 then
						ensureGradient()
						maid._gradient.Color = ColorSequence.new(value[1], value[2])
					end
				elseif typeof(value) == "ColorSequence" then
					parent.BackgroundColor3 = Color3.new(1, 1, 1)
					ensureGradient()
					maid._gradient.Color = value
				elseif typeof(value) == "Color3" then
					maid._gradient = nil
					parent.BackgroundColor3 = value
				else
					maid._gradient = nil
				end
			end)
		)

		return maid
	end)
end

return WxBackground
