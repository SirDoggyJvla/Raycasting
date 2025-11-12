---CACHE
local module = require "RaycastingLib/module"

---@class ObjectGeometry : ISBaseObject
---@field id string
---@field elements table<number, RLElement>
local ObjectGeometry = ISBaseObject:derive("ObjectGeometry")

function ObjectGeometry:testRayIntersection(...)
    for i = 1, #self.elements do
        local element = self.elements[i]
        local test = element:testIntersection(...)
        if test then
            return test
        end
    end
    return false
end

---Add a new geometry element to check for ray intersections.
---@param element RLElement
function ObjectGeometry:addElement(element)
    table.insert(self.elements, element)
end

---Creates a new geometry type with the given id.
---@param id string internal id of the geometry
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