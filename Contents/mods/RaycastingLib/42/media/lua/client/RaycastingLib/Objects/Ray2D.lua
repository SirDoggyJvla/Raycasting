--[[

TO IMPLEMENT RAYCASTING WITH DEPTH MAP, SEE:
https://discord.com/channels/908422782554107904/908422783049007116/1441167006236672043

in vanilla code for box coordinate retrieve:
```lua
function BoxPanel:render()
```

]]



---CACHE
local spriteRenderer = getRenderer()
--functions
local IsoUtils_XToScreen = IsoUtils.XToScreen
local IsoUtils_YToScreen = IsoUtils.YToScreen
local math_floor = math.floor
--debug
local isDebug = isDebugEnabled()


---@class Ray2D : ISUIElement
---@field public start_point Point
---@field public vector_beam Vector2
---@field private geometryCollection GeometryCollection
---@field public end_point Point
---@field public ray_color ColorRGBA?
---@field public square_color ColorRGBA?
---
---@field private squares Point[]
---@field private delta_length number
---
---@field private render_squares Point[]
---@field private markers {x: number, y: number, z: number, nametag: TextDrawObject, y_offset: number, height: number}[]
local Ray2D = ISUIElement:derive("Ray2D")


---[[=====================================]]
--- RENDERING
---[[=====================================]]

function Ray2D:render()
    --- RENDER RAY
    local zoom = getCore():getZoom(0)
    local cameraX = IsoCamera.getOffX()
	local cameraY = IsoCamera.getOffY()

    local start_point = self.start_point
    local end_point = self.end_point

    local x1, y1, z1 = start_point.x, start_point.y, start_point.z
    local x2, y2, z2 = end_point.x, end_point.y, end_point.z

    local sx1 = IsoUtils_XToScreen(x1, y1, z1, 0)
    local sy1 = IsoUtils_YToScreen(x1, y1, z1, 0)
    local sx2 = IsoUtils_XToScreen(x2, y2, z2, 0)
    local sy2 = IsoUtils_YToScreen(x2, y2, z2, 0)

    sx1 = (sx1 - cameraX)/zoom
    sy1 = (sy1 - cameraY)/zoom
    sx2 = (sx2 - cameraX)/zoom
    sy2 = (sy2 - cameraY)/zoom

    local ray_color = self.ray_color --[[@as ColorRGBA]]
    local r,g,b,a = ray_color.r, ray_color.g, ray_color.b, ray_color.a
    ---@diagnostic disable-next-line: param-type-mismatch
    spriteRenderer:renderline(nil,
        ---@diagnostic disable-next-line: param-type-mismatch
        sx1, sy1, -- start point
        ---@diagnostic disable-next-line: param-type-mismatch
        sx2, sy2, -- end point
        r, g, b, a, 1
    )


    --- RENDER SQUARES
    local squares = self.render_squares
    for i = 1, #squares do
        local c = squares[i]
        local square = getSquare(c.x, c.y, c.z)
        local x,y,z = square:getX(), square:getY(), square:getZ()
        local color = self.square_color --[[@as ColorRGBA]]
        local r,g,b,a = color.r, color.g, color.b, color.a

        addAreaHighlight(x, y, x+1, y+1, z, r, g, b, a)
    end


    --- RENDER MARKERS
    local markers = self.markers
    for i = 1, #markers do
        local marker = markers[i]
        local x, y, z = marker.x, marker.y, marker.z
        local sx = IsoUtils_XToScreen(x, y, z, 0)
        local sy = IsoUtils_YToScreen(x, y, z, 0)

        sx = sx - cameraX
        sy = sy - cameraY - marker.y_offset

        -- apply zoom
        sx = sx / zoom
        sy = sy / zoom
        sy = sy - marker.height

        marker.nametag:AddBatchedDraw(sx, sy, true)
    end
end

---[[=====================================]]
--- RAY CASTING
---[[=====================================]]

---Update the ray by casting to the next square. This can be called multiple times per frame 
---or updates can be spread over multiple frames for performances.
---
---Returns true if the ray has finished casting (all squares checked, or ray was blocked), false otherwise.
---@public
---@return boolean
function Ray2D:updateRay()
    local squares = self.squares
    if #squares <= 0 then return true end

    -- access next square and remove it
    local c = squares[1] --[[@as Point]]
    table.remove(squares, 1)
    local square = getSquare(c.x, c.y, c.z)
    if not square then return false end

    DebugLog.log("testing square "..tostring(square))

    local geometryCollection = self.geometryCollection

    -- check first type of objects
    local objects = square:getObjects()
    for i = 0, objects:size() - 1 do
		local object = objects:get(i)
        local test = geometryCollection:testObject(self, object)
        if test then
            DebugLog.log("Hit object:"..tostring(object))
            DebugLog.log("Hit object:"..tostring(test))
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
    print("cast")
    local interest = false
    while not interest do
        print("casting...")
        -- Ray casting logic here
        interest = self:updateRay()
        if interest then
            -- self.squares = {} -- clear remaining squares
            break
        end
        print(interest)
    end
    DebugLog.log("Ray casting finished")
end



function Ray2D:addMarker(point, text, r, g, b, a)
    text = tostring(text) -- safeguard

	local nametag = TextDrawObject.new()
	nametag:ReadString(UIFont.Small, text, -1)
    nametag:setDefaultColors(r or 1,g or 0,b or 0,a or 1)

	table.insert(self.markers, {
		x = point.x,
		y = point.y,
		z = point.z,
        y_offset = 0,
		nametag = nametag,
        height = nametag:getHeight(),
	})
end




---[[=====================================]]
--- CONSTRUCTOR
---[[=====================================]]

---Precalculate the squares to check during the cast using Amanatides algorithm [1, 2].
---
---[1] http://www.cse.yorku.ca/~amana/research/grid.pdf
---[2] https://m4xc.dev/articles/amanatides-and-woo/
function Ray2D:populateSquares()
    local squares = {}
    self.render_squares = {} -- for debug

    -- cache
    local start_point = self.start_point
    local vector_beam = self.vector_beam
    local z = start_point.z

    local x0, y0 = start_point.x, start_point.y
    local vx, vy = vector_beam:getX(), vector_beam:getY()
    
    local vlen = math.sqrt(vx * vx + vy * vy)
    if vlen == 0 then return end
    
    -- Normalize the direction vector
    vx = vx / vlen
    vy = vy / vlen

    -- Initialize step directions
    local stepX = vx > 0 and 1 or -1
    local stepY = vy > 0 and 1 or -1

    -- Calculate delta t values (parametric distance between grid lines)
    local tDeltaX = (vx ~= 0) and (1 / math.abs(vx)) or math.huge
    local tDeltaY = (vy ~= 0) and (1 / math.abs(vy)) or math.huge

    -- Start in grid cell
    local i = math_floor(x0)
    local j = math_floor(y0)
    
    -- Calculate initial tMax values
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

    -- Track the parametric distance traveled
    local t = 0.0

    -- Traverse grid cells
    while t < vlen do
        table.insert(squares, {x=i, y=j, z=z})
        if isDebug then
            table.insert(self.render_squares, {x=i, y=j, z=z})
        end

        -- Step to next grid cell
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
    self.squares = squares
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

---comment
---@param start_point Point
---@param vector_beam Vector2
---@param geometryCollection GeometryCollection
---@return Ray2D
function Ray2D:new(start_point, vector_beam, geometryCollection, _delta_length)
    local o = ISUIElement:new(0, 0, 0, 0) --[[@as Ray2D]]
    setmetatable(o, self)
    self.__index = self

    o.start_point = start_point
    o.vector_beam = vector_beam
    o.geometryCollection = geometryCollection

    -- optional
    o.delta_length = _delta_length or 0.01

    -- for debugging UI
    if isDebug then
        o.x = 0
        o.y = 0
        o.width = 0
        o.height = 0

        o.ray_color = {r=1, g=1, b=0, a=1}

        local color = getCore():getBadHighlitedColor()
        o.square_color = {r=color:getR(), g=color:getG(), b=color:getB(), a=0.1}
        o.markers = {}
    end

    -- initialize
    o:create()

    return o
end

return Ray2D