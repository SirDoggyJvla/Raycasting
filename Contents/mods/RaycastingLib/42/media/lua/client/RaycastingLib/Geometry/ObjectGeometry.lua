---CACHE
local module = require "RaycastingLib/module"

---@class ObjectGeometry : ISBaseObject
---@field id string
---@field elements table<number, ObjectGeometryElement>
local ObjectGeometry = ISBaseObject:derive("ObjectGeometry")

---Add a new geometry element to check for ray intersections.
---@param element ObjectGeometryElement
function ObjectGeometry:addElement(element)
    table.insert(self.elements, element)
end

---Creates a new geometry type with the given id.
---@param id string
---@return ObjectGeometry
function ObjectGeometry:new(id)
    local o = ISBaseObject:new() --[[@as ObjectGeometry]]
    setmetatable(o, self)
    self.__index = self
    o.id = id
    o.elements = {}

    module.OBJECT_GEOMETRIES[id] = o

    return o
end

return ObjectGeometry