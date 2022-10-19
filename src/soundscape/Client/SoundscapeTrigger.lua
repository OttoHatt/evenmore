--[=[
	@class SoundscapeTrigger
	@client

	Represents a soundscape trigger, constructed as a bounding box around the `SoundscapeTrigger` tagged adornee.
	It's reccomended that you also apply Nevermore's `Hide` tag so that triggers are visible in-editor but not in-game.

	The name of the soundscape to play is defined in the `Soundscape` attribute. Soundscapes are named and provided with [SoundScriptRegistryServiceClient]. Default soundscapes are defined in [SoundScriptConstants].

	Note that your trigger can be a [Model] or [BasePart].
	As intersections are found via vector maths (not with a .Touched event for example), you should disable `CanCollide`, `CanQuery`, and `CanTouch` wherever possible on [BasePart] triggers.

	![Image of two intersecting soundscape triggers](/evenmore/soundscape/triggers.png)
]=]

local require = require(script.Parent.loader).load(script)

local ATTRIBUTE_NAME = "Soundscape"

-- For more info: https://medium.com/@fraactality/single-matrix-point-obb-test-66724b9e1f84
local CompiledBoundingBoxUtils = require("CompiledBoundingBoxUtils")
local BaseObject = require("BaseObject")
local AdorneeUtils = require("AdorneeUtils")
local RxAttributeUtils = require("RxAttributeUtils")

local SoundscapeTrigger = setmetatable({}, BaseObject)
SoundscapeTrigger.ClassName = "SoundscapeTrigger"
SoundscapeTrigger.__index = SoundscapeTrigger

--[=[
	Constructs a new Soundscape Trigger. Should be done via [Binder]. See [SoundscapeServiceClient].
	@param bound Instance
	@return SoundscapeTrigger
]=]
function SoundscapeTrigger.new(bound: any)
	local self = setmetatable(BaseObject.new(bound), SoundscapeTrigger)

	local cframe, size = AdorneeUtils.getBoundingBox(bound)
	assert(cframe and size, "[SoundscapeTrigger] Invalid adornee! Can't derive center or size.")

	self._aabb = CompiledBoundingBoxUtils.compileBBox(cframe, size)
	self._name = self._obj:GetAttribute(ATTRIBUTE_NAME)
	self._volume = size.X * size.Y * size.Z

	return self
end

--[=[
    Checks if a point is within this trigger's bounding box.

    @param point Vector3
    @return boolean
]=]
function SoundscapeTrigger:CheckAABB(point: Vector3)
	return CompiledBoundingBoxUtils.testPointBBox(point, self._aabb)
end

--[=[
    Observe the name of the soundscape attached to this trigger.

    @return Observable<string>
]=]
function SoundscapeTrigger:ObserveName()
	return RxAttributeUtils.observeAttribute(self._obj, ATTRIBUTE_NAME)
end

--[=[
	Get the volume of this soundscape trigger.

	@return number
]=]
function SoundscapeTrigger:GetVolume()
	return self._volume
end

return SoundscapeTrigger
