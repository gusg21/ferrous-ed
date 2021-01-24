local loveframes = require("LoveFrames")
local Grid = require("lib.grid")
local Pattern = require("nes.pattern")

local ferrous = {
    -- NES
    nametable = nil,
    pattern = nil,
    palettes = {
        {{0, 0.2, 0.4, 1},
        {0.6, 0.1, 0.6, 1},
        {0.6, 0.3, 1, 1},
        {0.9, 0.8, 0.7, 1}},

        {{0, 0, 0, 1},
        {0.1, 0.3, 0.4, 1},
        {0.2, 0.8, 0.6, 1},
        {0.8, 0.9, 0.6, 1}},

        {{0, 0, 0, 1},
        {0.4, 0, 0, 1},
        {0.6, 0.1, 0.2, 1},
        {1, 0.8, 0.8, 1}},

        {{0, 0, 0, 1},
        {0.4, 0, 0.6, 1},
        {0.6, 0.3, 1, 1},
        {0.8, 0.7, 1, 1}},
    },
    attributeTable = {},

    -- interface
    padding = 5,
    export = function ()
        print("EXPORT")
    end,
    toolbar = nil,
    camera = {x = 0, y = 0},
    initialDragMouse = {x = 0, y = 0},
    initialDragCamera = {x = 0, y = 0},
    paletteSwapShader = love.graphics.newShader([[
        extern vec4 palette[4];
        vec4 effect(vec4 color,Image texture,vec2 texture_coords,vec2 pixel_coords)
        {
            return palette[int(Texel(texture,texture_coords).r*4)];
        }
        ]]),
    selectedTile = 0
}

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setBackgroundColor(0.1, 0.1, 0.2)

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
    ferrous.nametable:set(31, 29, 1)
    ferrous.nametable.width = 32
    ferrous.nametable.height = 30

    -- PATTERN
    ferrous.pattern = Pattern:new(love.graphics.newImage("res/CHR000.bmp"), nil)

    -- ATTRIBUTE TABLE
    for i = 0, 240-1 do
        ferrous.attributeTable[i] = 0
    end
    ferrous.attributeTable[239] = 1
end

function love.update(dt)
    loveframes.update(dt)
    
    if (ferrous.initialDragCamera and ferrous.initialDragMouse and love.mouse.isDown(1)) then
        ferrous.camera.x = ferrous.initialDragCamera.x + (love.mouse.getX() - ferrous.initialDragMouse.x)
        ferrous.camera.y = ferrous.initialDragCamera.y + (love.mouse.getY() - ferrous.initialDragMouse.y)
    end
end

function love.draw()
    love.graphics.push()
    love.graphics.translate(ferrous.camera.x, ferrous.camera.y)
    love.graphics.scale(2, 2)
    love.graphics.setShader(ferrous.paletteSwapShader)

    for y = 0, ferrous.nametable.height-1 do
        for x = 0, ferrous.nametable.width-1 do
            local byte = ferrous.nametable:get(x, y)

            -- print(math.floor(y / 2) * 16 + math.floor(x / 2))
            ferrous.paletteSwapShader:send("palette", unpack(ferrous.palettes[ferrous.attributeTable[math.floor(y / 2) * 16 + math.floor(x / 2)]+1]))
            ferrous.pattern:draw(byte, x * 8, y * 8, nil)
        end
    end

    love.graphics.setShader()
    love.graphics.pop()

	love.graphics.setColor(1, 1, 1, 1)
    loveframes.draw()
    
    local gfxw, gfxh = love.graphics.getDimensions()
    local fpw = ferrous.pattern:getWidth() * 2
    local fph = ferrous.pattern:getHeight() * 2
    love.graphics.rectangle("fill", gfxw - fpw - 3, gfxh - fph - 3, fpw + 6, fph + 6)
    love.graphics.draw(ferrous.pattern:getImage(), gfxw - fpw, gfxh - fph, nil, 2, 2)
    love.graphics.setColor(0.9, 0.1, 0.1, 1)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", gfxw - fpw + (ferrous.selectedTile % 16) * 16, gfxh - fph + math.floor(ferrous.selectedTile / 16) * 16, 16, 16)
end

function love.mousepressed(x, y, button)
    loveframes.mousepressed(x, y, button)
    
    if (button == 1) then
        ferrous.initialDragCamera.x = ferrous.camera.x
        ferrous.initialDragCamera.y = ferrous.camera.y

        ferrous.initialDragMouse.x = x
        ferrous.initialDragMouse.y = y
    end

    local gfxw, gfxh = love.graphics.getDimensions()
    local fpw = ferrous.pattern:getWidth() * 2
    local fph = ferrous.pattern:getHeight() * 2
    if (x > gfxw - fpw and y > gfxh - fph) then
        ferrous.selectedTile = math.floor((love.mouse.getX() - (gfxw - fpw)) / 16) + math.floor((love.mouse.getY() - (gfxh - fph)) / 16) * 16
        print(ferrous.selectedTile)
    end
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