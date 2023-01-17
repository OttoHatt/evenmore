--[=[
	@class EffectValue

	Given a base number value, apply compounding multipliers on top.
	Useful for levelling-up, simulators, etc.

	For more advanced functionality, see Quenty's [RogueProperty].
]=]

local require = require(script.Parent.loader).load(script)

local ObservableList = require("ObservableList")
local BaseObject = require("BaseObject")
local Blend = require("Blend")
local RxBrioUtils = require("RxBrioUtils")
local RxValueBaseUtils = require("RxValueBaseUtils")
local Rx = require("Rx")

local EffectValue = setmetatable({}, BaseObject)
EffectValue.ClassName = "EffectValue"
EffectValue.__index = EffectValue

--[=[
	Constructs a new [EffectValue].
	@param baseValue number -- The final value when no multipliers are applied
	@return EffectValue
]=]
function EffectValue.new(baseValue: number)
	local self = setmetatable(BaseObject.new(), EffectValue)

	assert(typeof(baseValue) == "number", "Bad baseValue")

	self._baseValue = Instance.new("NumberValue")
	self._baseValue.Value = baseValue
	self._maid:GiveTask(self._baseValue)

	self._multiplierList = ObservableList.new()
	self._maid:GiveTask(self._multiplierList)

	-- Cache our value to avoid expensive brio list fluff with each listener.
	-- TODO: Swap out for Rx.cache()?
	self._value = Instance.new("NumberValue")
	self._maid:GiveTask(Blend.mount(self._value, {
		Value = self:_observeFinalValue(),
	}))
	self._maid:GiveTask(self._value)

	return self
end

function EffectValue:_observeFinalValue()
	return Rx.combineLatest({
		multiplier = self:_observeMultiplier(),
		base = self:_observeBaseValue(),
	}):Pipe({
		Rx.map(function(data)
			return data.base * data.multiplier
		end),
	})
end

function EffectValue:_observeMultiplier()
	-- This method is very expensive! Only use when the result is cached!
	return self._multiplierList:ObserveItemsBrio():Pipe({
		RxBrioUtils.reduceToAliveList(),
		RxBrioUtils.map(function(aliveList: { number })
			local value = 1

			for _, multiplier in aliveList do
				value *= multiplier
			end

			return value
		end),
		RxBrioUtils.emitOnDeath(1),
		Rx.defaultsTo(1),
	})
end

function EffectValue:_observeBaseValue()
	return RxValueBaseUtils.observeValue(self._baseValue)
end

--[=[
	Push a multiplier (i.e. 'effect') onto the base value.

	All multipliers are multiplied together before being applied. This means they compound.
	```
	i.e. with multipliers (1, 1, 1) => baseValue * 1.
	i.e. with multipliers (1, 1.5, 0.3) => baseValue * 0.15.
	```

	@param multiplier number
	@return callback -- Call to remove
]=]
function EffectValue:PushMultiplier(multiplier: number)
	assert(typeof(multiplier) == "number", "Bad multiplier")

	return self._multiplierList:Add(multiplier)
end

--[=[
	Observe the final value, after all multipliers have been compounded.

	@return Observable<number>
]=]
function EffectValue:Observe()
	return RxValueBaseUtils.observeValue(self._value)
end

--[=[
	Gets the current compounded value.

	@return number
]=]
function EffectValue:GetValue()
	return self._value.Value
end

--[=[
	Set the base value of the effect.
	Note that this will automatically update the final value, and notify any observers.

	@param baseValue number -- The final value when no multipliers are applied.
]=]
function EffectValue:SetBaseValue(baseValue: number)
	assert(typeof(baseValue) == "number", "Bad baseValue")

	self._baseValue.Value = baseValue
end

return EffectValue
