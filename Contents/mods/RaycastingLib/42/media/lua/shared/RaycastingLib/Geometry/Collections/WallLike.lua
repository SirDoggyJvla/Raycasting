---@namespace RaycastingLib

local GeometryCollection = require "RaycastingLib/Geometry/GeometryCollection"
local ObjectGeometry = require "RaycastingLib/Geometry/ObjectGeometry"
local RLSegment = require "RaycastingLib/Geometry/Default/RLSegment"

---Describes a collection of wall-like objects, such as walls, windows and doors.
---@class WallLikeCollection : GeometryCollection
---@field private validProperties IsoFlagType[]
---@field private geometries table<IsoFlagType, ObjectGeometry>
local WallLikeCollection = GeometryCollection:derive("WallLike")



---@type table<IsoFlagType, {x: number, y: number, x_offset?: number, y_offset?: number}[]>
local types = {
    [IsoFlagType.WallN] = {
        {x=1, y=0, y_offset = 0},
    },
    [IsoFlagType.WallW] = {
        {x=0, y=-1, y_offset = 1},
    },
    [IsoFlagType.WallNW] = {
        {x=1, y=0, y_offset = 0},
        {x=0, y=-1, y_offset = 1},
    },
    [IsoFlagType.WindowN] = {
        {x=1, y=0, y_offset = 0},
    },
    [IsoFlagType.WindowW] = {
        {x=0, y=-1, y_offset = 1},
    },
    [IsoFlagType.DoorN] = {
        {x=1, y=0, y_offset = 0},
    },
    [IsoFlagType.DoorW] = {
        {x=0, y=-1, y_offset = 1},
    },
}



for type, segments in pairs(types) do
    -- create geometry associated to the type
    local geometry = ObjectGeometry:new("WallLike_"..tostring(type))
    for i = 1, #segments do
        local seg = segments[i]
        local C = {x=seg.x_offset or 0, y=seg.y_offset or 0, z=0}
        local D = {x=C.x + seg.x, y=C.y + seg.y, z=0}
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


---@param spriteProperties PropertyContainer
function WallLikeCollection:_getObjectType(object, spriteProperties)
    local _type = object:getType()
    _type = tostring(_type)

    local validProperties = self.validProperties
    for i = 1, #validProperties do
        local property = validProperties[i]
        if spriteProperties:has(property) or property == _type then
            return property, self.geometries[property]
        end
    end

	return nil, nil
end


function WallLikeCollection:testObject(ray, object)
    local sprite = object:getSprite()
    if not sprite then return false end

    local spriteProperties = sprite:getProperties()
    if not spriteProperties then return false end

    local objectProperty, geometry = self:_getObjectType(object, spriteProperties)
    if not objectProperty or not geometry then return false end

    local start_point = ray.start_point
    local end_point = ray.end_point
    local vector = ray.vector_beam
    local location = {x=object:getX(), y=object:getY(), z=object:getZ()}
    local test = geometry:testRayIntersection(start_point, end_point, vector, location)
    return test
end

