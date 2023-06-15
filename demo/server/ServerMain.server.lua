--[[
	@class ServerMain
]]

local ServerScriptService = game:GetService("ServerScriptService")

local loader = ServerScriptService:FindFirstChild("LoaderUtils", true).Parent
local packages = require(loader).bootstrapGame(ServerScriptService.demo)

local serviceBag = require(packages.ServiceBag).new()

serviceBag:Init()
serviceBag:Start()