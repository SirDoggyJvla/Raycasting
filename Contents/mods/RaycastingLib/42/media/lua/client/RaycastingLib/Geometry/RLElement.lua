---@class RLElement : ISBaseObject
local RLElement = ISBaseObject:derive("RLElement")

function RLElement:new()
    local o = ISBaseObject:new() --[[@as RLElement]]
    setmetatable(o, self)
    self.__index = self
    return o
end

return RLElement