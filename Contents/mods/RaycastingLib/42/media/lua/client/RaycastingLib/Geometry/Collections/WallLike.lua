local GeometryCollection = require "RaycastingLib/Geometry/GeometryCollection"
local ObjectGeometry = require "RaycastingLib/Geometry/ObjectGeometry"
local RLSegment = require "RaycastingLib/Geometry/Default/RLSegment"

local types = {
    ["WallN"] = {
        {1,0,y_offset = 0},
    },
    ["WallW"] = {
        {0,-1,y_offset = 1},
    },
    ["WallNW"] = {
        {1,0,y_offset = 0},
        {0,-1,y_offset = 1},
    },
    ["WindowN"] = {
        {1,0,y_offset = 0},
    },
    ["WindowW"] = {
        {0,-1,y_offset = 1},
    },
    ["DoorN"] = {
        {1,0,y_offset = 0},
    },
    ["DoorW"] = {
        {0,-1,y_offset = 1},
    },
}

---@class WallLikeCollection : GeometryCollection
local WallLikeCollection = GeometryCollection:derive("WallLike")
for type, segments in pairs(types) do
    -- create geometry associated to the type
    local geometry = ObjectGeometry:new("WallLike_"..type)
    for i = 1, #segments do
        local seg = segments[i]
        local C = {x=seg.x_offset or 0, y=seg.y_offset or 0, z=0}
        local D = {x=C.x + seg[1], y=C.y + seg[2], z=0}
        local errorMargin = 0.05
        local segment = RLSegment:new(C, D, errorMargin)
        geometry:addElement(segment)
    end

    -- add the geometry to the collection
    WallLikeCollection:addObjectGeometry(type, geometry)
end

function WallLikeCollection:create()
    local geometries = self.geometries
    local validProperties = {}
    for type, geometry in pairs(geometries) do
        table.insert(validProperties, type)
    end
    self.validProperties = validProperties
end


function WallLikeCollection:_getObjectType(object, spriteProperties)
    ---@type IsoObjectType|string just bcs Lua typing shows a warning when there shouldn't be one
    local _type = object:getType()
    _type = tostring(_type)

    local validProperties = self.validProperties
    for i = 1, #validProperties do
        local property = validProperties[i]
        if spriteProperties:Is(property) or property == _type then
            return property, self.geometries[property]
        end
    end

	return nil, nil
end

function WallLikeCollection:testObject(ray, object)
    local sprite = object:getSprite()
    if not sprite then return nil end

    local spriteProperties = sprite:getProperties()
    if not spriteProperties then return nil end

    local objectProperty, geometry = self:_getObjectType(object, spriteProperties)
    if not objectProperty or not geometry then return nil end

    local start_point = ray.start_point
    local end_point = ray.end_point
    local vector = ray.vector_beam
    local location = {x=object:getX(), y=object:getY(), z=object:getZ()}
    local test = geometry:testRayIntersection(start_point, end_point, vector, location)
    return test
end