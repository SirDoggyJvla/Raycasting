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
---@field private squares table<number, Point>
---@field private delta_length number
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
        sx1, sy1, -- start point
        sx2, sy2, -- end point
        r, g, b, a
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
    for i = 1,#markers do
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

---Update the ray by casting to the next square. This can be called multiple times per frame or updates can be spread over multiple frames for performances.
---
---Returns true if the ray has finished casting (all squares checked, or ray was blocked), false otherwise.
---@public
---@return boolean
function Ray2D:update()
    local squares = self.squares
    if #squares <= 0 then return true end

    -- access next square and remove it
    local c = squares[1]
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
            self:addMarker(test, "Hit", 1, 0, 0, 1)
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
    while not interest do
        -- Ray casting logic here
        interest = self:update()
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

---Precalculate the squares to check during the cast.
function Ray2D:populateSquares()
    local already_calculated = {}
    ---@cast already_calculated table<number, table<number, table<number, true>>>

    local squares = {}
    local render_squares = {}

    -- cache
    local start_point = self.start_point
    local vector_beam = self.vector_beam
    local delta_length = self.delta_length

    local delta_vector = vector_beam:clone():setLength(self.delta_length)
    local deltaX, deltaY = delta_vector:getX(), delta_vector:getY()

    local x, y, z = start_point.x, start_point.y, start_point.z

    -- iterate over the beam length
    local beam_length = vector_beam:getLength()
    while beam_length > 0 do
        -- calculate next position along the ray
        local x2, y2 = x + deltaX, y + deltaY

        -- floor to square coordinates
        local x3, y3 = math_floor(x2), math_floor(y2)

        -- verify if square was already calculated
        already_calculated[x3] = already_calculated[x3] or {}
        if not already_calculated[x3][y3] then
            -- new square, register
            already_calculated[x3][y3] = already_calculated[x3][y3] or true
            table.insert(squares, {x=x3, y=y3, z=z})
            if isDebug then
                table.insert(render_squares, {x=x3, y=y3, z=z})
            end
        end

        -- update position
        x, y = x2, y2
        beam_length = beam_length - delta_length
    end

    -- store results
    self.squares = squares
    self.render_squares = render_squares
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