--[=[
	@class SliderModel

	Provides measurements for the user clicking + dragging across a slider.
]=]

local require = require(script.Parent.loader).load(script)

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local BaseObject = require("BaseObject")
local Maid = require("Maid")
local RxBrioUtils = require("RxBrioUtils")
local RxInstanceUtils = require("RxInstanceUtils")
local ValueObject = require("ValueObject")

local SliderModel = setmetatable({}, BaseObject)
SliderModel.ClassName = "SliderModel"
SliderModel.__index = SliderModel

function SliderModel.new(obj)
	local self = setmetatable(BaseObject.new(obj), SliderModel)

	self._fracValue = ValueObject.new(0, "number")
	self._maid:GiveTask(self._fracValue)

	self._referenceGuiValue = Instance.new("ObjectValue")
	self._maid:GiveTask(self._referenceGuiValue)

	self._inputActiveValue = ValueObject.new(false, "boolean")
	self._maid:GiveTask(self._inputActiveValue)

	return self
end

function SliderModel:SetValue(value: number)
	self._fracValue.Value = value
end

function SliderModel:GetValue(): number
	return self._fracValue.Value
end

function SliderModel:ObserveValue()
	return self._fracValue:Observe()
end

function SliderModel:ObserveInputActive()
	return self._inputActiveValue:Observe()
end

function SliderModel:SetCatchElement(element: GuiObject)
	assert(typeof(element) == "Instance" and element:IsA("GuiObject"), "Bad element")

	local maid = Maid.new()
	self._maid._catchMaid = maid

	-- TODO: With this, we don't support multi-touch. Does Roblox even support it? Use a stack of input objects?

	maid:GiveTask(element.InputBegan:Connect(function(inputObject: InputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			-- This input is probably freshest.
			self:_updateMouse(inputObject.Position)

			self._inputActiveValue.Value = true

			-- Use a named connection so that later input steal priority from the first.
			-- Means that if we have multiple fingers on
			-- We don't worry about GCing here. This instance is going to be destroyed!
			maid._inputConn = inputObject:GetPropertyChangedSignal("UserInputState"):Connect(function()
				if inputObject.UserInputState == Enum.UserInputState.End then
					self._inputActiveValue.Value = false
					maid._inputConn = nil
				end
			end)
		end
	end))

	maid:GiveTask(RxBrioUtils.flatCombineLatest({
		layerAncestor = RxInstanceUtils.observeFirstAncestorBrio(element, "LayerCollector"),
		inputActive = self:ObserveInputActive(),
	}):Subscribe(function(values)
		local collector: PluginGui | ScreenGui = values.layerAncestor
		local inputActive: boolean = values.inputActive

		if collector and inputActive then
			if collector:IsA("PluginGui") then
				self:_updateMouse(collector:GetRelativeMousePosition())
				maid._mouseConn = RunService.Heartbeat:Connect(function()
					self:_updateMouse(collector:GetRelativeMousePosition())
				end)
			elseif values.layerAncestor:IsA("ScreenGui") then
				self:_updateMouse(UserInputService:GetMouseLocation())
				maid._mouseConn = UserInputService.InputChanged:Connect(function(inputObject: InputObject)
					if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
						self:_updateMouse(UserInputService:GetMouseLocation())
					end
				end)
			end
		else
			maid._mouseConn = nil
		end
	end))
end

function SliderModel:SetReferenceElement(element: GuiBase2d)
	assert(typeof(element) == "Instance" and element:IsA("GuiBase2d"), "Bad element")

	self._referenceGuiValue.Value = element
end

function SliderModel:_updateMouse(rawPosition: Vector2 & Vector3)
	local pos = Vector2.new(rawPosition.X, rawPosition.Y)

	local referenceElement: GuiBase2d? = self._referenceGuiValue.Value
	if referenceElement then
		local off = pos - referenceElement.AbsolutePosition
		local fac = math.clamp(off.X / referenceElement.AbsoluteSize.X, 0, 1)

		self:SetValue(fac)
	end
end

return SliderModel
