local class = require("lib.middleclass")
local Pattern = class("Pattern")

-- Represents a pattern table
function Pattern:initialize(image, srcPalette)
    self.image = image
    self.srcPalette = srcPalette 
end

function Pattern:getWidth() return self.image:getWidth() end
function Pattern:getHeight() return self.image:getHeight() end

function Pattern:getImage() return self.image end

function Pattern:draw(byte, x, y, palette)
    local quad = love.graphics.newQuad(byte % 16 * 8, math.floor(byte / 16) * 8, 8, 8, 128, 128)

    love.graphics.draw(self.image, quad, x, y)
end

return Pattern