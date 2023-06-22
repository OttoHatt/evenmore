--[=[
	@class RefCountedLut

	Ref-counted table.
	Designed to be used by observables with cleanup methods, so a resource can be mutually destroyed.
	This object shouldn't require any manual cleanup.
]=]

local require = require(script.Parent.loader).load(script)

type RefRemoveCallback = () -> nil
type RefNode = { RefCount: number, Obj: any, RemoveCallback: RefRemoveCallback }

local MaidTaskUtils = require("MaidTaskUtils")

local RefCountedLut = {}
RefCountedLut.ClassName = "RefCountedLut"
RefCountedLut.__index = RefCountedLut

function RefCountedLut.new(constructor)
	local self = setmetatable({}, RefCountedLut)

	self._constructor = constructor

	self._nodeLut = {}

	self._inFlight = 0

	return self
end

function RefCountedLut:Get(key: any): (table, RefRemoveCallback)
	local node: RefNode = self:_getAndPushRef(key)
	return node.Obj, node.RemoveCallback
end

-- function RefCountedLut:RevokeOnce(key: any)
-- 	self:_clawbackRef(key)
-- end

function RefCountedLut:WeakGet(key: any): any?
	local node: RefNode? = self._nodeLut[key]
	return node and node.Obj
end

function RefCountedLut:_getAndPushRef(key: any): RefNode
	local node: RefNode? = self._nodeLut[key]

	if not node then
		-- Object doesn't exist at all yet!
		node = {
			Obj = self._constructor(),
			RemoveCallback = function()
				self:_clawbackRef(key)
			end,
			RefCount = 1,
		}
		self._inFlight += 1
		self._nodeLut[key] = node
		return node
	else
		node.RefCount += 1
		return node
	end
end

function RefCountedLut:_clawbackRef(key: any)
	local node: RefNode? = self._nodeLut[key]

	if node and node.RefCount == 1 then
		-- We're destroying the last ref. GC it!
		self._nodeLut[key] = nil
		MaidTaskUtils.doTask(node.Obj)
		self._inFlight -= 1
	elseif node and node.RefCount > 1 then
		-- We have at least 1 other ref left after this.
		node.RefCount -= 1
	else
		error(`[RefCountedLut] Attempted to claw back key '{key}' when it's already been destroyed!`)
	end
end

return RefCountedLut
