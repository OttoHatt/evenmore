local require = require(game:GetService("ServerScriptService"):FindFirstChild("LoaderUtils", true).Parent).load(script)

local Maid = require("Maid")
local StoryBarUtils = require("StoryBarUtils")

return function(target)
	local maid = Maid.new()

	local bar = StoryBarUtils.createStoryBar(maid, target)
	StoryBarUtils.createButton(bar, "Click button")
	StoryBarUtils.createSwitch(bar, "Toggle switch", false)
	StoryBarUtils.createSlider(bar, "Linear slider", 0.5)

	return function()
		maid:DoCleaning()
	end
end
