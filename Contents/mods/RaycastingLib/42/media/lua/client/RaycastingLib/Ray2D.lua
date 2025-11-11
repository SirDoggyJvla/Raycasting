---CACHE
local spriteRenderer = getRenderer()
--functions
local IsoUtils_XToScreen = IsoUtils.XToScreen
local IsoUtils_YToScreen = IsoUtils.YToScreen


---@class Ray2D : ISUIElement
---@field public start_point Point
---@field public vector_beam Vector2
---@field public end_point Point
---@field public ray_color ColorRGBA?
local Ray2D = ISUIElement:derive("Ray2D")


---[[=====================================]]
--- RENDERING
---[[=====================================]]

function Ray2D:render()
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

    sx1 = sx1 - cameraX
    sy1 = sy1 - cameraY
    sx2 = sx2 - cameraX
    sy2 = sy2 - cameraY

    local ray_color = self.ray_color --[[@as ColorRGBA]]
    local r,g,b,a = ray_color.r, ray_color.g, ray_color.b, ray_color.a
    ---@diagnostic disable-next-line: param-type-mismatch
    spriteRenderer:renderline(nil,
        sx1, sy1, -- start point
        sx2, sy2, -- end point
        r, g, b, a
    )
end






---[[=====================================]]
--- CONSTRUCTOR
---[[=====================================]]

function Ray2D:calculateEndPoint(start_point, vector_beam)
    self.end_point = {
        x = start_point.x + vector_beam:getX(),
        y = start_point.y + vector_beam:getY(),
        z = start_point.z
    }
end

---comment
---@param start_point Point
---@param vector_beam Vector2
---@return Ray2D
function Ray2D:new(start_point, vector_beam)
    local o = ISUIElement:new(0, 0, 0, 0) --[[@as Ray2D]]
    setmetatable(o, self)
    self.__index = self

    o.start_point = start_point
    o.vector_beam = vector_beam
    o:calculateEndPoint(start_point, vector_beam)

    -- for debugging UI
    if isDebugEnabled() then
        self.x = 0
        self.y = 0
        self.width = getCore():getScreenWidth()
        self.height = getCore():getScreenHeight()

        self.ray_color = {r=1, g=0, b=0, a=1}
    end

    return o
end

return Ray2D