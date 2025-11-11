local ObjectGeometry = require "RaycastingLib/Geometry/ObjectGeometry"
local ObjectSegment = require "RaycastingLib/Geometry/ObjectSegment"

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


local Wall = ObjectGeometry:new("WallN")
Wall:addElement(ObjectSegment:new(1, 0, 0.1))