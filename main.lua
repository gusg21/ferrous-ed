local loveframes = require("LoveFrames")
local Grid = require("lib.grid")
local Pattern = require("nes.pattern")

local ferrous = {
    padding = 5,
    export = function ()
        print("EXPORT")
    end,
    toolbar = nil,
    nametable = nil,
    pattern = nil
}

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- UI
    ferrous.toolbar = loveframes.Create("panel")
    ferrous.toolbar:SetSize(love.graphics.getWidth(), 35)
    ferrous.toolbar:SetPos(0, 0)

    local exportBtn = loveframes.Create("button", ferrous.toolbar)
    exportBtn:SetText("Export")
    exportBtn:SetPos(ferrous.padding, ferrous.padding)
    exportBtn.OnClick = function (obj, x, y)
        ferrous.export()
    end

    -- NAMETABLE
    ferrous.nametable = Grid:new()
    for y = 0, 30-1 do
        for x = 0, 32-1 do
            ferrous.nametable:set(x, y, 0)
        end
    end
    ferrous.nametable:set(0, 0, 1)

    -- PATTERN
    ferrous.pattern = Pattern:new(love.graphics.newImage("res/CHR000.bmp"), nil)
end

function love.update(dt)
	loveframes.update(dt)
end

function love.draw()
    love.graphics.push()
    love.graphics.translate(0, 35)
    love.graphics.scale(4, 4)

    for y = 0, 30-1 do
        for x = 0, 32-1 do
            local byte = ferrous.nametable:get(x, y)

            ferrous.pattern:draw(byte, x * 8, y * 8, nil)
        end
    end

    love.graphics.pop()

	love.graphics.setColor(1, 1, 1, 1)
	loveframes.draw()
end

function love.mousepressed(x, y, button)
	loveframes.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
	loveframes.mousereleased(x, y, button)
end

function love.wheelmoved(x, y)
	loveframes.wheelmoved(x, y)
end

function love.keypressed(key, isrepeat)
	loveframes.keypressed(key, isrepeat)
end

function love.keyreleased(key)
	loveframes.keyreleased(key)
end

function love.textinput(text)
    loveframes.textinput(text)
end