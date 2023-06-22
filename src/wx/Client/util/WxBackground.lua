--[=[
	@class WxBackground

	Generate a polymorphic background / gradient thing.
]=]

local require = require(script.Parent.loader).load(script)

local Blend = require("Blend")
local Maid = require("Maid")
local Observable = require("Observable")

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

		local function handleValue(value: { Color3 } | ColorSequence | Color3 | nil)
			if typeof(value) == "table" and #value == 1 then
				maid._gradient = nil
				parent.BackgroundColor3 = value[1]
			elseif typeof(value) == "table" then
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
		end

		local observable = Blend.toPropertyObservable(topValue)
		if observable then
			maid:GiveTask(observable:Subscribe(handleValue))
		else
			-- If we can't convert to an observable, this will be some kind of literal.
			-- Just apply it, and hope we've got the correct type.
			handleValue(topValue)
		end

		return maid
	end)
end

return WxBackground
