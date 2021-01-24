local class = require("lib.middleclass")
local UiComp = class("UiComp")

UiComp.static.all = {}
UiComp.static.staticPos = function (x) 
    return function()
        return x
    end
end

function UiComp:keypressed(key)
end

function UiComp:mousepressed(x, y)
end

function UiComp:update(dt)
end

function UiComp:draw()
end

return UiComp