---CACHE
local module = require "RaycastingLib/module"

---@class GeometryCollection : ISBaseObject
---@field id string
---@field geometries table<number, ObjectGeometry>
local GeometryCollection = ISBaseObject:derive("GeometryCollection")

function GeometryCollection:create()
    -- IMPLEMENT ME
end

---Tests the given object by retrieving its geometry and testing if it intersects with the ray.
---@param object IsoObject
---@return any
function GeometryCollection:testObject(ray, object)
    ---IMPLEMENT ME
    return false
end

function GeometryCollection:addObjectGeometry(id, geometry)
    self.geometries[id] = geometry
end

---@param id string
---@return GeometryCollection
function GeometryCollection:derive(id)
    local o = ISBaseObject:derive("GeometryCollection_"..id) --[[@as GeometryCollection]]
    setmetatable(o, self)
    self.__index = self
    o.id = id
    o.geometries = {}

    module.OBJECT_COLLECTIONS[id] = o

    return o
end

return GeometryCollection