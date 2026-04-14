---@namespace RaycastingLib


---CACHE
local spriteRenderer = getRenderer()

---@class Ray2DRenderer : ISUIElement
---@field parent Ray2D
---@field ray_color ColorRGBA
---@field square_color ColorRGBA
---
---@field render_squares Point[]
---@field markers {x: number, y: number, z: number, nametag: TextDrawObject, y_offset: number, height: number}[]
local Ray2DRenderer = ISUIElement:derive("Ray2DRenderer")


function Ray2DRenderer:render()
    --- RENDER RAY
    local zoom = getCore():getZoom(0)
    local cameraX = IsoCamera.getOffX()
	local cameraY = IsoCamera.getOffY()

    local start_point = self.parent.start_point
    local end_point = self.parent.end_point

    local x1, y1, z1 = start_point.x, start_point.y, start_point.z
    local x2, y2, z2 = end_point.x, end_point.y, end_point.z

    local sx1 = IsoUtils.XToScreen(x1, y1, z1, 0)
    local sy1 = IsoUtils.YToScreen(x1, y1, z1, 0)
    local sx2 = IsoUtils.XToScreen(x2, y2, z2, 0)
    local sy2 = IsoUtils.YToScreen(x2, y2, z2, 0)

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
    local square_points = self.parent.square_points
    local color = self.square_color
    for i = 1, #square_points do
        local c = square_points[i]
        local square = getSquare(c.x, c.y, c.z)
        local x,y,z = square:getX(), square:getY(), square:getZ()
        local r,g,b,a = color.r, color.g, color.b, color.a

        addAreaHighlight(x, y, x+1, y+1, z, r, g, b, a)
    end


    --- RENDER MARKERS
    local markers = self.markers
    for i = 1, #markers do
        local marker = markers[i]
        local x, y, z = marker.x, marker.y, marker.z
        local sx = IsoUtils.XToScreen(x, y, z, 0)
        local sy = IsoUtils.YToScreen(x, y, z, 0)

        sx = sx - cameraX
        sy = sy - cameraY - marker.y_offset

        -- apply zoom
        sx = sx / zoom
        sy = sy / zoom
        sy = sy - marker.height

        marker.nametag:AddBatchedDraw(sx, sy, true)
    end
end


---@param point Point
---@param text string
---@param r number
---@param g number
---@param b number
---@param a number
function Ray2DRenderer:addMarker(point, text, r, g, b, a)
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

---@param point Point
function Ray2DRenderer:addSquare(point)
    table.insert(self.render_squares, point)
end




---@param parent Ray2D
---@return Ray2DRenderer
function Ray2DRenderer:new(parent)
    ---@type Ray2DRenderer
    local o = ISUIElement.new(self, 0, 0, 0, 0)

    print("creating renderer")

    o.parent = parent

    o.x = 0
    o.y = 0
    o.width = 0
    o.height = 0    

    o.ray_color = {r=1, g=1, b=0, a=1}

    local color = getCore():getBadHighlitedColor()
    o.square_color = {r=color:getR(), g=color:getG(), b=color:getB(), a=0.1}
    
    o.render_squares = {}
    o.markers = {}

    return o
end



return Ray2DRenderer