---@namespace RaycastingLib

local module = require("RaycastingLib/module")
local Ray2D = require("RaycastingLib/Objects/Ray2D")

local RAY
if isDebugEnabled() then
    Events.OnKeyPressed.Add(function(key)
        if key == Keyboard.KEY_X then
            local player = getPlayer()
            if RAY then
                player:addLineChatElement("Ray removed")
                if (RAY.renderer) then
                    RAY.renderer:removeFromUIManager()
                end
                RAY = nil
            else
                player:addLineChatElement("Ray created")
                local start_point = {
                    x = player:getX(),
                    y = player:getY(),
                    z = player:getZ(),
                }

                local vector_beam = player:getLastAngle():setLength(10)

                RAY = Ray2D:new(start_point, vector_beam, module.OBJECT_COLLECTIONS["WallLike"])
                RAY:cast()
            end
        end
    end)
end