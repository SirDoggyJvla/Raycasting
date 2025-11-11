---@class ObjectGeometryElement : ISBaseObject
local ObjectGeometryElement = ISBaseObject:derive("ObjectGeometryElement")

function ObjectGeometryElement:new()
    local o = ISBaseObject:new() --[[@as ObjectGeometryElement]]
    setmetatable(o, self)
    self.__index = self
    return o
end

return ObjectGeometryElement