local Grid = require("lib.grid")
local Pattern = require("nes.pattern")
local ToolBtn = require("toolbtn")

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
    camera = {x = 0, y = 0, zoom = 3, 
    toWorld = function (self, x, y)
        return (x - self.x) / self.zoom, (y - self.y) / self.zoom
    end},
    initialDragMouse = {x = 0, y = 0},
    initialDragCamera = {x = 0, y = 0},
    paletteSwapShader = love.graphics.newShader([[
        extern vec4 palette[4];
        vec4 effect(vec4 color,Image texture,vec2 texture_coords,vec2 pixel_coords)
        {
            return palette[int(Texel(texture,texture_coords).r*4)];
        }
        ]]),
    selectedTile = 0,
    toolBtns = {},
}

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setBackgroundColor(0.1, 0.1, 0.2)

    ferrous.toolBtns = {
        ToolBtn:new("res/draw.png", 10, 10, "draw", "p"),
        ToolBtn:new("res/move.png", 10, 45, "move", "m"),
        ToolBtn:new("res/save.png", 10, 80, "save", "s"),
    }

    -- NAMETABLE
    ferrous.nametable = Grid:new()
    for y = 0, 30-1 do
        for x = 0, 32-1 do
            ferrous.nametable:set(x, y, 0)
        end
    end
    -- ferrous.nametable:set(31, 29, 1)
    ferrous.nametable.width = 32
    ferrous.nametable.height = 30

    -- PATTERN
    ferrous.pattern = Pattern:new(love.graphics.newImage("res/CHR000.bmp"), nil)

    -- ATTRIBUTE TABLE
    for i = 0, 240-1 do
        ferrous.attributeTable[i] = 0
    end
    -- ferrous.attributeTable[239] = 1
end

function love.update(dt)
    -- CAMERA MOVING
    if (ferrous.initialDragCamera and ferrous.initialDragMouse and love.mouse.isDown(1) and ToolBtn.static.tool == "move") then
        ferrous.camera.x = ferrous.initialDragCamera.x + (love.mouse.getX() - ferrous.initialDragMouse.x)
        ferrous.camera.y = ferrous.initialDragCamera.y + (love.mouse.getY() - ferrous.initialDragMouse.y)
    end

    -- NAMETABLE EDITING
    local mx, my = ferrous.camera:toWorld(love.mouse.getX(), love.mouse.getY())
    if (mx > 0 and mx < ferrous.nametable.width * 8 and 
            my > 0 and my < ferrous.nametable.height * 8 and ToolBtn.static.tool == "draw") then
        local tx = math.floor(mx / 8)
        local ty = math.floor(my / 8)

        if (love.mouse.isDown(1)) then
            ferrous.nametable:set(tx, ty, ferrous.selectedTile)
        elseif (love.mouse.isDown(2)) then
            ferrous.selectedTile = ferrous.nametable:get(tx, ty)
        end
    end
end

function love.draw()
    -- NAMETABLE
    love.graphics.push()
    love.graphics.translate(ferrous.camera.x, ferrous.camera.y)
    love.graphics.scale(ferrous.camera.zoom, ferrous.camera.zoom)
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

    -- BUTTONS
    for i,v in ipairs(ferrous.toolBtns) do
        v:draw()
    end
    love.graphics.setColor(1, 1, 1, 1)
    
    -- PATTERN SELECTOR
    local gfxw, gfxh = love.graphics.getDimensions()
    local fpw = ferrous.pattern:getWidth() * 2
    local fph = ferrous.pattern:getHeight() * 2
    love.graphics.rectangle("fill", gfxw - fpw - 3, gfxh - fph - 3, fpw + 6, fph + 6)
    love.graphics.draw(ferrous.pattern:getImage(), gfxw - fpw, gfxh - fph, nil, 2, 2)
    love.graphics.setColor(0.9, 0.1, 0.1, 1)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", gfxw - fpw + (ferrous.selectedTile % 16) * 16, gfxh - fph + math.floor(ferrous.selectedTile / 16) * 16, 16, 16)

    -- print(ferrous.camera:toWorld(love.mouse.getX(), love.mouse.getY()))
end

function love.mousepressed(x, y, button)
    for _,v in pairs(ferrous.toolBtns) do
        v:mousepressed(x, y)
    end

    -- PANNING
    if (button == 1 and ToolBtn.static.tool == "move") then
        ferrous.initialDragCamera.x = ferrous.camera.x
        ferrous.initialDragCamera.y = ferrous.camera.y

        ferrous.initialDragMouse.x = x
        ferrous.initialDragMouse.y = y
    end

    -- Pattern selection
    local gfxw, gfxh = love.graphics.getDimensions()
    local fpw = ferrous.pattern:getWidth() * 2
    local fph = ferrous.pattern:getHeight() * 2
    if (x > gfxw - fpw and y > gfxh - fph) then
        ferrous.selectedTile = math.floor((x - (gfxw - fpw)) / 16) + math.floor((y - (gfxh - fph)) / 16) * 16
        print(ferrous.selectedTile)
    end
end

function love.keypressed(key, scancode, isRepeat)
    for _,v in pairs(ferrous.toolBtns) do
        v:keypressed(key)
    end
end

function love.quit()
end