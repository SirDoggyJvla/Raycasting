--[[

TO IMPLEMENT RAYCASTING WITH DEPTH MAP, SEE:
https://discord.com/channels/908422782554107904/908422783049007116/1441167006236672043

in vanilla code for box coordinate retrieve:
```lua
function BoxPanel:render()
```

]]

local isClientOrSP = isClient() or not isClient() and not isServer()



---@namespace RaycastingLib


---CACHE
local isDebug = isDebugEnabled()


---@class Ray2D
---
---The start point of the ray.
---@field start_point Point
---
---The end point of the ray, calculated from the start point and the vector beam.
---@field end_point Point
---
---The direction and length of the ray.
---@field vector_beam Vector2
---
---Holds a collection of objects that will be used to test for intersection during the ray cast.
---@field geometryCollection GeometryCollection
---
---Holds the coordinates of the squares to check during the ray cast. This is populated at ray creation using Amanatides algorithm.
---@field square_points Point[]
---
---A debug renderer to visualize the ray and the squares being checked. Also used to show the impact point.
---@field renderer Ray2DRenderer? -- only for client, nil on server
local Ray2D = {}


---[[=====================================]]
--- RAY CASTING
---[[=====================================]]

---Update the ray by casting to the next square. This can be called multiple times per frame 
---or updates can be spread over multiple frames for performances.
---
---Returns true if the ray has finished casting (all squares checked, or ray was blocked), false otherwise.
---@param i number
---@return boolean
function Ray2D:updateRay(i)
    local square_points = self.square_points
    if #square_points < i then return true end

    -- access next square and remove it
    local c = square_points[i] --[[@as Point]]
    local square = getSquare(c.x, c.y, c.z)
    if not square then return false end

    DebugLog.log("testing square "..tostring(square))

    local geometryCollection = self.geometryCollection

    -- check first type of objects
    local objects = square:getObjects()
    for j = 0, objects:size() - 1 do
		local object = objects:get(j)
        local test = geometryCollection:testObject(self, object)
        if test then
            self:addMarker(test, "X", 1, 1, 1, 1)
            return true
        end
    end

    -- check second type of objects
    -- local objects = square:getSpecialObjects()

    return false
end

---Cast the ray in a single frame.
function Ray2D:cast()
    local interest = false
    local i = 1
    while not interest do
        print("casting...")
        -- Ray casting logic here
        interest = self:updateRay(i)
        if interest then
            -- self.squares = {} -- clear remaining squares
            break
        end
        i = i + 1
        if i > 1000 then -- safeguard to prevent infinite loops during testing
            DebugLog.log("Ray casting loop exceeded 1000 iterations, breaking to prevent infinite loop.")
            break
        end
    end
    DebugLog.log("Ray casting finished")
end



---@param point Point
---@param text string
---@param r number
---@param g number
---@param b number
---@param a number
function Ray2D:addMarker(point, text, r, g, b, a)
    if not self.renderer then return end
    self.renderer:addMarker(point, text, r, g, b, a)
end

---@param point Point
function Ray2D:addSquare(point)
    if not self.renderer then return end
    self.renderer:addSquare(point)
end


---[[=====================================]]
--- CONSTRUCTOR
---[[=====================================]]

---Precalculate the squares to check during the cast using Amanatides algorithm [1, 2].
---
---[1] http://www.cse.yorku.ca/~amana/research/grid.pdf
---[2] https://m4xc.dev/articles/amanatides-and-woo/
function Ray2D:populateSquares()
    local square_points = {}

    -- cache
    local start_point = self.start_point
    local vector_beam = self.vector_beam
    local z = start_point.z

    local x0, y0 = start_point.x, start_point.y
    local vx, vy = vector_beam:getX(), vector_beam:getY()
    
    local vlen = math.sqrt(vx * vx + vy * vy)
    if vlen == 0 then return end
    
    -- normalize the direction vector
    vx = vx / vlen
    vy = vy / vlen

    -- initialize step directions
    local stepX = vx > 0 and 1 or -1
    local stepY = vy > 0 and 1 or -1

    -- calculate delta t values (parametric distance between grid lines)
    local tDeltaX = (vx ~= 0) and (1 / math.abs(vx)) or math.huge
    local tDeltaY = (vy ~= 0) and (1 / math.abs(vy)) or math.huge

    -- start in grid cell
    local i = math.floor(x0)
    local j = math.floor(y0)
    
    -- calculate initial tMax values
    local tMaxX, tMaxY
    if stepX > 0 then
        tMaxX = (i + 1 - x0) * tDeltaX
    else
        tMaxX = (x0 - i) * tDeltaX
    end
    
    if stepY > 0 then
        tMaxY = (j + 1 - y0) * tDeltaY
    else
        tMaxY = (y0 - j) * tDeltaY
    end

    -- track the parametric distance traveled
    local t = 0.0

    -- traverse grid cells
    while t < vlen do
        table.insert(square_points, {x=i, y=j, z=z})

        -- step to next grid cell
        if tMaxX < tMaxY then
            t = tMaxX
            i = i + stepX
            tMaxX = tMaxX + tDeltaX
        else
            t = tMaxY
            j = j + stepY
            tMaxY = tMaxY + tDeltaY
        end
    end

    -- store results
    self.square_points = square_points
end

---Calculate the end point.
---@param start_point Point
---@param vector_beam Vector2
function Ray2D:calculateEndPoint(start_point, vector_beam)
    self.end_point = {
        x = start_point.x + vector_beam:getX(),
        y = start_point.y + vector_beam:getY(),
        z = start_point.z
    }
end

---Update the ray to fit its current settings
function Ray2D:create()
    -- debug
    self.render_squares = {}
    self.markers = {}

    local start_point = self.start_point
    local vector_beam = self.vector_beam
    self:calculateEndPoint(start_point, vector_beam)
    self:populateSquares()
    self.geometryCollection:create()
end

---Update the vector beam and recreate the ray.
---@param vector_beam Vector2
function Ray2D:setVectorBeam(vector_beam)
    self.vector_beam = vector_beam
    self:create()
end

---Create a new ray element.
---@param start_point Point
---@param vector_beam Vector2
---@param geometryCollection GeometryCollection
---@return Ray2D
function Ray2D:new(start_point, vector_beam, geometryCollection)
	local o = {}
	setmetatable(o, self)
	self.__index = self

    ---@cast o Ray2D

    o.start_point = start_point
    o.vector_beam = vector_beam
    o.geometryCollection = geometryCollection

    -- initialize
    o:create()

    -- for debugging UI
    if isClientOrSP then
        o.renderer = require("RaycastingLib/Ray2DRenderer"):new(o)
        o.renderer:addToUIManager()
    end

    return o
end

return Ray2D