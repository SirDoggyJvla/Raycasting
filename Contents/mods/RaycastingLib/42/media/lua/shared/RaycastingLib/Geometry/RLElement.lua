---@namespace RaycastingLib

---@class RLElement : ISBaseObject
local RLElement = ISBaseObject:derive("RLElement")

---@return Point|false
function RLElement:testIntersection(...)
    -- IMPLEMENT ME
    return false
end

function RLElement:new()
    local o = ISBaseObject:new() --[[@as RLElement]]
    setmetatable(o, self)
    self.__index = self
    return o
end

return RLElement