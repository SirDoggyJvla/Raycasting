---CACHE
local RLElement = require "RaycastingLib/Geometry/RLElement"
local math_min = math.min
local math_max = math.max

---@class RLSegment : RLElement
---@field C_point Point
---@field D_point Point
---@field errorMargin number
local RLSegment = RLElement:derive("RLSegment")

---Checks if the point (Px, Py) is within the segment [x1, y1] to [x2, y2]. `errorMargin` is used to expand the segment's bounding box to reduce error on segment to segment boundaries.
---@param Px number
---@param Py number
---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@param errorMargin number
---@return boolean
---@return number
---@return number
---@return number
---@return number
function RLSegment:isPointInSegment(Px, Py, x1, y1, x2, y2, errorMargin)
	local minX, maxX = math_min(x1, x2), math_max(x1, x2)
	local minY, maxY = math_min(y1, y2), math_max(y1, y2)

	-- Add error margin and consider if segment is not axis-aligned
	if minX ~= maxX then
		minX = minX - errorMargin
		maxX = maxX + errorMargin
	end
	if minY ~= maxY then
		minY = minY - errorMargin
		maxY = maxY + errorMargin
	end

	-- VisualMarkers.AddLine({x=minX,y=minY,z=0}, {x=maxX,y=maxY,z=0}, 0.5, 0, 1, 0.05)
	return Px >= minX and Px <= maxX and Py >= minY and Py <= maxY, minX, maxX, minY, maxY
end

---Used to check for the intersection of segment [AB] and segment [CD] (see [1]). The theorical intersection point is called (Px, Py).
---
---For `vector` being a Vector3, we consider that the section is a plane perpendicular to the XY plane. Which is how we determine the Z coordinate of the intersection point.
---
---[1]: https://en.wikipedia.org/wiki/Line–line_intersection
---@param start_point Point
---@param end_point Point
---@param vector Vector2|Vector3
---@param location Point -- the location of the object in the world
---@return Point|false
function RLSegment:testIntersection(start_point, end_point, vector, location)
    -- the ray points A and B
	local xA, yA = start_point.x, start_point.y
	local xB, yB = end_point.x, end_point.y

    -- the segment points C and D
    local C_point = self.C_point
    local D_point = self.D_point
    local x_real, y_real = location.x, location.y -- used to go from relative to absolute coordinates
    local xC = C_point.x + x_real
    local yC = C_point.y + y_real
    local xD = D_point.x + x_real
    local yD = D_point.y + y_real

    local denom = (xB - xA) * (yD - yC) - (yB - yA) * (xD - xC)
	if denom == 0 then
		return false -- lines are parallel or coincident
	end

    local errorMargin = self.errorMargin

	local Px = ( (xA*yB - yA*xB)*(xC-xD) - (xA-xB)*(xC*yD - yC*xD) )/denom
	local Py = ( (xA*yB - yA*xB)*(yC-yD) - (yA-yB)*(xC*yD - yC*xD) )/denom

    local inSegmentCD, minX, maxX, minY, maxY = self:isPointInSegment(Px, Py, xC, yC, xD, yD, errorMargin)

	if not inSegmentCD or not self:isPointInSegment(Px, Py, xA, yA, xB, yB, 0) then
		return false -- intersection point is not within one or both segments
	end

    -- determine z, we use an intercept theorem approach
    -- See the segment-segment_intercept.md file
    local zA, zB = start_point.z, end_point.z
    local z
    if zA ~= zB then
        local EB = zB - zA
        local AF = math.sqrt((Px - xA)^2 + (Py - yA)^2)
        local AE = math.sqrt((xB - xA)^2 + (yB - yA)^2)
        local ratio = (AF / AE) * EB
        z = zA + ratio

        -- we consider that a segment describes a full vertical wall, and the wall is 1 z unit tall + errorMargin
        if z - math.floor(zA) > 1 + errorMargin then return false end
    else -- most cases this is a ray as a Vector2
        z = zA
    end

    return {
        x=Px,
        y=Py,
        z=z,

        -- used for debug rendering
        maxX=maxX, minX=minX,
        maxY=maxY, minY=minY,
    }
end

---Constructor
---@param C_point Point
---@param D_point Point
---@param _errorMargin number?
---@return RLSegment
function RLSegment:new(C_point, D_point, _errorMargin)
    local o = RLElement:new() --[[@as RLSegment]]
    setmetatable(o, self)
    self.__index = self

    o.C_point = C_point
    o.D_point = D_point
    o.errorMargin = _errorMargin or 0
    return o
end

return RLSegment