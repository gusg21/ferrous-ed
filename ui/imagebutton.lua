local class = require("lib.middleclass")
local UiComp = require("ui.uicomp")
local ImageButton = class("ImageButton", UiComp)

function ImageButton:initialize(x, y, image, onClick)
    table.insert(UiComp.static.all, self)

    self.x = x
    self.y = y
    self.image = image
    self.onClick = onClick
end

function ImageButton:pointOnButton(x, y)
    return x > self.x() and x < self.x() + self.image:getWidth() and y > self.y() and y < self.y() + self.image:getHeight()
end

function ImageButton:mousepressed(x, y)
    if (self:pointOnButton(x, y)) then
        self.onClick()
        return true
    end
end

function ImageButton:update(dt)
    local x, y = love.mouse.getPosition()
    if (self:pointOnButton(x, y)) then
        -- self.onClick()
        return true
    end
end

function ImageButton:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", self.x(), self.y(), self.image:getWidth(), self.image:getHeight())
    love.graphics.draw(self.image, self.x(), self.y())
    love.graphics.setColor(1, 1, 1, 1)
end

return ImageButton
