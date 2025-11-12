---CACHE
local module = require "RaycastingLib/module"

---@class GeometryCollection : ISBaseObject
---@field id string
---@field geometries table<number, ObjectGeometry>
local GeometryCollection = ISBaseObject:derive("GeometryCollection")

function GeometryCollection:addObjectGeometry(id, geometry)
    self.geometries[id] = geometry
end

---@param id string
---@return GeometryCollection
function GeometryCollection:new(id)
    local o = ISBaseObject:new() --[[@as GeometryCollection]]
    setmetatable(o, self)
    self.__index = self
    o.id = id
    o.geometries = {}

    module.OBJECT_COLLECTIONS[id] = o

    return o
end

return GeometryCollection