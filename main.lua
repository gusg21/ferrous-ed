local loveframes = require("LoveFrames")

local ferrous = {
    padding = 5,
    export = function ()
        print("EXPORT")
    end,
    toolbar = nil,
}

function love.load()
    ferrous.toolbar = loveframes.Create("panel")
    ferrous.toolbar:SetSize(love.graphics.getWidth(), 35)
    ferrous.toolbar:SetPos(0, 0)

    local exportBtn = loveframes.Create("button", ferrous.toolbar)
    exportBtn:SetText("Export")
    exportBtn:SetPos(ferrous.padding, ferrous.padding)
    exportBtn.OnClick = function (obj, x, y)
        ferrous.export()
    end
end

function love.update(dt)
	loveframes.update(dt)
end

function love.draw()
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