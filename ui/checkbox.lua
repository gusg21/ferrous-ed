local class = require("lib.middleclass")
local UiComp = require("ui.uicomp")
local Checkbox = class("Checkbox", UiComp)

Checkbox.static.uncheckedImg = love.graphics.newImage("res/unchecked.png")
Checkbox.static.checkedImg = love.graphics.newImage("res/checked.png")

function Checkbox:initialize(x, y, label, labelOnLeft, checked)
    table.insert(UiComp.static.all, self)

    self.checked = checked or false
    self.label = label
    self.x = x
    self.y = y
    self.labelOnLeft = labelOnLeft or false
end

function Checkbox:mousepressed(x, y)
    if x > self.x() and x < self.x() + Checkbox.static.checkedImg:getWidth() and y > self.y() and y < self.y() + Checkbox.static.checkedImg:getHeight() then
        self.checked = not self.checked
    end
end

function Checkbox:draw()
    if self.labelOnLeft then
        love.graphics.print(self.label, self.x() - love.graphics.getFont():getWidth(self.label) - 5, self.y() + Checkbox.static.checkedImg:getHeight() / 2 - love.graphics.getFont():getHeight(self.label) / 2)
    else
        love.graphics.print(self.label, self.x() + Checkbox.static.checkedImg:getWidth() + 5, self.y() + Checkbox.static.checkedImg:getHeight() / 2 - love.graphics.getFont():getHeight(self.label) / 2)
    end

    if self.checked then
        love.graphics.draw(Checkbox.static.checkedImg, self.x(), self.y())
    else
        love.graphics.draw(Checkbox.static.uncheckedImg, self.x(), self.y())
    end
end

return Checkbox