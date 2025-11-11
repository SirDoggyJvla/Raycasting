local module = require "RaycastingLib/module"
require "RaycastingLib/debug"

if isDebugEnabled() then
    Events.OnKeyPressed.Add(module.OnKeyPressed)
end