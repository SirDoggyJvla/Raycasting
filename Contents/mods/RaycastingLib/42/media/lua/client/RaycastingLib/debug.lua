if not isDebugEnabled() then return end

---CACHE
local module = require "RaycastingLib/module"
local Ray2D = require "RaycastingLib/Objects/Ray2D"

module.OnKeyPressed = function(key)
    if key == Keyboard.KEY_X then
        local player = getPlayer()
        if module.ray then
            player:addLineChatElement("Ray removed")
            module.ray:removeFromUIManager()
            module.ray = nil
        else
            player:addLineChatElement("Ray created")
            local start_point = {
                x = player:getX(),
                y = player:getY(),
                z = player:getZ(),
            }

            local vector_beam = player:getLastAngle():setLength(10)

            module.ray = Ray2D:new(start_point, vector_beam, module.OBJECT_COLLECTIONS["WallLike"])
            module.ray:addToUIManager()
            module.ray:cast()
        end
    end
end