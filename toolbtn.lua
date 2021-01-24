local class = require("lib.middleclass")
local ToolBtn = class("ToolBtn")

ToolBtn.static.selectedId = 0
ToolBtn.static.nextId = 0
ToolBtn.static.tool = ""

function ToolBtn:initialize(imagePath, x, y, toolName, key)
    self.image = love.graphics.newImage(imagePath)
    self.x = x
    self.y = y
    self.toolName = toolName
    self.key = key
    self.id = ToolBtn.static.nextId
    ToolBtn.static.nextId = ToolBtn.static.nextId + 1
    if self.id == 0 then
        ToolBtn.static.tool = toolName
    end
end

function ToolBtn:select()
    ToolBtn.static.selectedId = self.id
    ToolBtn.static.tool = self.toolName
end

function ToolBtn:mousepressed(x, y)
    if (x > self.x and y > self.y and x < self.x + self.image:getWidth() and y < self.y + self.image:getHeight()) then
        self:select()
    end
end

function ToolBtn:keypressed(key) 
    if (key == self.key) then
        self:select()
    end 
end

function ToolBtn:draw()
    love.graphics.setColor(1, 1, 1, 1)
    if ToolBtn.static.selectedId == self.id then
        love.graphics.setColor(.9, .1, .1, 1)
        love.graphics.rectangle("line", self.x - 2, self.y - 2, self.image:getWidth() + 4, self.image:getHeight() + 4)
        love.graphics.setColor(1, 1, 1, 1)
    end
    love.graphics.rectangle("fill", self.x, self.y, self.image:getWidth(), self.image:getHeight())
    love.graphics.draw(self.image, self.x, self.y)
end

return ToolBtn