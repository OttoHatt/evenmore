--[=[
	@class BaseBarElement
	@private
	@ignore

	Base element for story bar.
]=]

local require = require(script.Parent.loader).load(script)

local PADDING = 8

local BaseObject = require("BaseObject")
local Blend = require("Blend")
local EvenmoreColorTheming = require("EvenmoreColorTheming")

local BaseBarElement = setmetatable({}, BaseObject)
BaseBarElement.ClassName = "BaseBarElement"
BaseBarElement.__index = BaseBarElement

function BaseBarElement.new(serviceBag)
	local self = setmetatable(BaseObject.new(), BaseBarElement)

	self._serviceBag = assert(serviceBag, "No serviceBag")
	self._colorTheming = serviceBag:GetService(EvenmoreColorTheming)

	self._sizeValue = Instance.new("Vector3Value")
	self._maid:GiveTask(self._sizeValue)

	self._maid:GiveTask(self:_renderBase():Subscribe(function(gui)
		self.Gui = gui
	end))

	return self
end

function BaseBarElement:GetPadding()
	return PADDING
end

function BaseBarElement:GetSizeValue()
	return self._sizeValue
end

function BaseBarElement:RenderPadding()
	local padding = self:GetPadding()
	return Blend.New("UIPadding")({
		PaddingLeft = UDim.new(0, padding),
		PaddingRight = UDim.new(0, padding),
		PaddingBottom = UDim.new(0, padding),
		PaddingTop = UDim.new(0, padding),
	})
end

function BaseBarElement:_renderBase()
	return Blend.New("Frame")({
		Size = Blend.Computed(self._sizeValue, function(size: Vector3)
			return UDim2.fromOffset(size.X, size.Y)
		end),
		BackgroundColor3 = self._colorTheming:ObserveColor("Neutral"),
		[Blend.Children] = {
			Blend.New("UICorner")({
				CornerRadius = UDim.new(0, 4),
			}),
		},
	})
end

return BaseBarElement
