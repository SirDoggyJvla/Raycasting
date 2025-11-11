---@class GeometryObject : ISBaseObject
local GeometryObject = ISBaseObject:derive("GeometryObject")

function GeometryObject:new()
    local o = ISBaseObject:new() --[[@as GeometryObject]]
    setmetatable(o, self)
    self.__index = self
    return o
end

return GeometryObject