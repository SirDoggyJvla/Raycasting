---CACHE
local GeometryObject = require "RaycastingLib/Objects/GeometryObject"
local math_min = math.min
local math_max = math.max

---@class ObjectSegment : ISBaseObject
---@field start_point Point
---@field end_point Point
---@field errorMargin number
local ObjectSegment = GeometryObject:derive("ObjectSegment")

---Checks if the point (Px, Py) is within the segment [x1, y1] to [x2, y2]. `errorMargin` is used to expand the segment's bounding box to reduce error on segment to segment boundaries.
---@param Px any
---@param Py any
---@param x1 any
---@param y1 any
---@param x2 any
---@param y2 any
---@param errorMargin any
---@return boolean
---@return any
---@return any
---@return any
---@return any
function ObjectSegment:isPointInSegment(Px, Py, x1, y1, x2, y2, errorMargin)
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
---@return Point|false
function ObjectSegment:testIntersection(start_point, end_point, vector)
    -- the ray points A and B
	local x1, y1 = start_point.x, start_point.y
	local x2, y2 = end_point.x, end_point.y

    -- the segment points C and D
    local x3, y3 = self.start_point.x, self.start_point.y
    local x4, y4 = self.end_point.x, self.end_point.y

    local denom = (x2 - x1) * (y4 - y3) - (y2 - y1) * (x4 - x3)
	if denom == 0 then
		return false -- lines are parallel or coincident
	end

    local errorMargin = self.errorMargin

	local Px = ( (x1*y2 - y1*x2)*(x3-x4) - (x1-x2)*(x3*y4 - y3*x4) )/denom
	local Py = ( (x1*y2 - y1*x2)*(y3-y4) - (y1-y2)*(x3*y4 - y3*x4) )/denom

    local inSegmentCD, minX, maxX, minY, maxY = self:isPointInSegment(Px, Py, x3, y3, x4, y4, errorMargin)

	if not inSegmentCD or not self:isPointInSegment(Px, Py, x1, y1, x2, y2, 0) then
		return false -- intersection point is not within one or both segments
	end

    -- determine z, we use an intercept theorem approach
    -- https://en.wikipedia.org/wiki/Intercept_theorem
    -- here we consider: AD/AB = AP/AC = DP/BC
    -- where:
    -- A is the intersect point (start_point)
    -- B is the end_point
    -- AD is perpendicular to DP and BC
    -- the segment-segment_intercept.md file
    local z1, z2 = start_point.z, end_point.z
    local z
    if z1 ~= z2 then
        local BC = z2 - z1
        local AD = math.sqrt((Px - x1)^2 + (Py - y1)^2)
        local AB = math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
        local ratio = (AD / AB) * BC
        z = z1 + ratio

        -- we consider that a segment describes a wall, and the wall is 1 z unit tall + errorMargin
        if z - math.floor(z1) > 1 + errorMargin then return false end
    else -- most cases this is a ray as a Vector2
        z = z1
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
---@param start_point Point
---@param end_point Point
---@param _errorMargin number?
---@return ObjectSegment
function ObjectSegment:new(start_point, end_point, _errorMargin)
    local o = GeometryObject:new() --[[@as ObjectSegment]]
    setmetatable(o, self)
    self.__index = self
    o.start_point = start_point
    o.end_point = end_point
    o.errorMargin = _errorMargin or 0
    return o
end

return ObjectSegment