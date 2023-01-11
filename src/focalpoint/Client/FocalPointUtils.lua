--[=[
	@class FocalPointUtils
	@client

	Tries to find the position that we, the client, are most interested in.
	This could be the character, of the current camera position. Not sure!

	We do this is in a pretty neat way, which is watching the [Camera.CameraSubject].
	It should therefore support custom characters, humanoids, and studio.
]=]

local require = require(script.Parent.loader).load(script)

local AdorneeUtils = require("AdorneeUtils")
local RxInstanceUtils = require("RxInstanceUtils")
local Rx = require("Rx")

local FocalPointUtils = {}

--[=[
	Gets the focal point via the [Workspace.CurrentCamera].

	@return Vector3
]=]
function FocalPointUtils.getFocalPoint(): Vector3
	-- I'm assuming that this is always safe...
	local camera: Camera = workspace.CurrentCamera

	return if camera.CameraSubject then AdorneeUtils.getCenter(camera.CameraSubject) else camera.CFrame.Position
end

--[=[
	Observe the position of a given instance.

	@ignore
	@within FocalPointUtils
	@return Observable<Vector3>
]=]
local function observeInstancePosition(instance: Instance)
	return RxInstanceUtils.observeProperty(instance, "Position")
end

--[=[
	Observes the focal point via the [Workspace.CurrentCamera].

	@return Observable<Vector3>
]=]
function FocalPointUtils.observeFocalPoint()
	return RxInstanceUtils.observeProperty(workspace, "CurrentCamera"):Pipe({
		Rx.where(function(camera)
			return camera ~= nil
		end),
		Rx.switchMap(function(camera: Camera)
			return RxInstanceUtils.observeProperty(camera, "CameraSubject"):Pipe({
				Rx.switchMap(function(subject: Instance)
					-- Prioritise watching the subject over the camera itself.
					return observeInstancePosition(subject or camera)
				end)
			})
		end)
	})
end

return FocalPointUtils
