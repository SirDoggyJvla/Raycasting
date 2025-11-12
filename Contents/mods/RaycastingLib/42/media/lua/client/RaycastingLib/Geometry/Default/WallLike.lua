local ObjectGeometry = require "RaycastingLib/Geometry/ObjectGeometry"
local RLSegment = require "RaycastingLib/Geometry/RLSegment"

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

for type, segments in pairs(types) do
    local geometry = ObjectGeometry:new(type)
    for i = 1, #segments do
        local seg = segments[i]
        local C = {x=seg.x_offset or 0, y=seg.y_offset or 0, z=0}
        local D = {x=C.x + seg[1], y=C.y + seg[2], z=0}
        local errorMargin = 0.05
        local segment = RLSegment:new(C, D, errorMargin)
        geometry:addElement(segment)
    end

end