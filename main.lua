local Grid = require("lib.grid")
local Pattern = require("nes.pattern")

local UiComp = require("ui.uicomp")
local ToolBtn = require("ui.toolbtn")
local Checkbox = require("ui.checkbox")
local ImageButton = require("ui.imagebutton")

love.graphics.setDefaultFilter("nearest", "nearest")
love.graphics.setBackgroundColor(0.1, 0.1, 0.2)
love.filesystem.setIdentity("ferrous")

local ferrous = {
    -- NES
    nametable = nil,
    pattern = nil,
    palettes = {{{0, 0.2, 0.4, 1}, {0.6, 0.1, 0.6, 1}, {0.6, 0.3, 1, 1}, {0.9, 0.8, 0.7, 1}},

                {{0, 0, 0, 1}, {0.1, 0.3, 0.4, 1}, {0.2, 0.8, 0.6, 1}, {0.8, 0.9, 0.6, 1}},

                {{0, 0, 0, 1}, {0.4, 0, 0, 1}, {0.6, 0.1, 0.2, 1}, {1, 0.8, 0.8, 1}},

                {{0, 0, 0, 1}, {0.4, 0, 0.6, 1}, {0.6, 0.3, 1, 1}, {0.8, 0.7, 1, 1}}},
    attributeTable = {},

    -- interface
    padding = 5,
    camera = {
        x = 0,
        y = 0,
        zoom = 3,
        toWorld = function(self, x, y)
            return (x - self.x) / self.zoom, (y - self.y) / self.zoom
        end
    },
    initialDragMouse = {
        x = 0,
        y = 0
    },
    initialDragCamera = {
        x = 0,
        y = 0
    },
    paletteSwapShader = love.graphics.newShader([[
        extern vec4 palette[4];
        vec4 effect(vec4 color,Image texture,vec2 texture_coords,vec2 pixel_coords)
        {
            return palette[int(Texel(texture,texture_coords).r*4)];
        }
        ]]),

    selectedTile = 0,
    selectedPalette = 1,
    selectedPaletteSprite = love.graphics.newImage("res/arrow.png"),

    toolBtns = {ToolBtn:new("res/draw.png", UiComp.static.staticPos(10), UiComp.static.staticPos(10), "draw", "p"),
                ToolBtn:new("res/move.png", UiComp.static.staticPos(10), UiComp.static.staticPos(45), "move", "m")},
    paintPalette = Checkbox:new(function()
        return love.graphics.getWidth() - 259
    end, function()
        return love.graphics.getHeight() - 288
    end, "Paint Palette", false, true),
    paintTiles = Checkbox:new(function()
        return love.graphics.getWidth() - 259
    end, function()
        return love.graphics.getHeight() - 313
    end, "Paint Tiles", false, true),
    exportButton = ImageButton:new(UiComp.static.staticPos(45), UiComp.static.staticPos(10),
        love.graphics.newImage("res/save.png"), function()
            export()
        end)
}

function replace_char(pos, str, r)
    return str:sub(1, pos-1) .. r .. str:sub(pos+1)
end

function export()
    local str = ""
    local x = 0
    local y = 0
    for _,row in pairs(ferrous.nametable.cells) do
        for _,item in pairs(row) do
            str = str .. string.char(item)
        end
    end

    print("["..str.."]")
    local result, message = love.filesystem.write("test.nam", str)
    if (not result) then
        print(message)
    end
end

function love.load()
    -- NAMETABLE
    ferrous.nametable = Grid:new()
    for y = 0, 30 - 1 do
        for x = 0, 32 - 1 do
            ferrous.nametable:set(x, y, 0)
        end
    end
    -- ferrous.nametable:set(31, 29, 1)
    ferrous.nametable.width = 32
    ferrous.nametable.height = 30

    -- PATTERN
    ferrous.pattern = Pattern:new(love.graphics.newImage("res/CHR000.bmp"), nil)

    -- ATTRIBUTE TABLE
    for i = 0, 240 - 1 do
        ferrous.attributeTable[i] = 0
    end
    -- ferrous.attributeTable[239] = 1
end

function love.update(dt)
    -- UI
    for _, v in pairs(UiComp.static.all) do
        if v:update(dt) then
            return
        end
    end

    -- CAMERA MOVING
    if (ferrous.initialDragCamera and ferrous.initialDragMouse and love.mouse.isDown(1) and ToolBtn.static.tool ==
        "move") then
        ferrous.camera.x = ferrous.initialDragCamera.x + (love.mouse.getX() - ferrous.initialDragMouse.x)
        ferrous.camera.y = ferrous.initialDragCamera.y + (love.mouse.getY() - ferrous.initialDragMouse.y)
    end

    -- NAMETABLE EDITING
    local mx, my = ferrous.camera:toWorld(love.mouse.getX(), love.mouse.getY())
    if (mx > 0 and mx < ferrous.nametable.width * 8 and my > 0 and my < ferrous.nametable.height * 8 and
        ToolBtn.static.tool == "draw") then
        local tx = math.floor(mx / 8)
        local ty = math.floor(my / 8)

        if (love.mouse.isDown(1)) then
            if ferrous.paintTiles.checked then
                ferrous.nametable:set(tx, ty, ferrous.selectedTile)
            end
            if ferrous.paintPalette.checked then
                ferrous.attributeTable[math.floor(tx / 2) + math.floor(ty / 2) * 16] = ferrous.selectedPalette
            end
        elseif (love.mouse.isDown(2)) then
            if ferrous.paintTiles.checked then
                ferrous.selectedTile = ferrous.nametable:get(tx, ty)
            end
            if ferrous.paintPalette.checked then
                ferrous.selectedPalette = ferrous.attributeTable[math.floor(tx / 2) + math.floor(ty / 2) * 16]
            end
        end
    end
end

function love.draw()
    -- NAMETABLE
    love.graphics.push()
    love.graphics.translate(ferrous.camera.x, ferrous.camera.y)
    love.graphics.scale(ferrous.camera.zoom, ferrous.camera.zoom)
    love.graphics.setShader(ferrous.paletteSwapShader)
    for y = 0, ferrous.nametable.height - 1 do
        for x = 0, ferrous.nametable.width - 1 do
            local byte = ferrous.nametable:get(x, y)

            -- print(math.floor(y / 2) * 16 + math.floor(x / 2))
            ferrous.paletteSwapShader:send("palette", unpack(
                ferrous.palettes[ferrous.attributeTable[math.floor(y / 2) * 16 + math.floor(x / 2)] + 1]))
            ferrous.pattern:draw(byte, x * 8, y * 8, nil)
        end
    end
    love.graphics.setShader()
    love.graphics.pop()

    -- UI
    for i, v in ipairs(UiComp.static.all) do
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
    love.graphics.rectangle("line", gfxw - fpw + (ferrous.selectedTile % 16) * 16,
        gfxh - fph + math.floor(ferrous.selectedTile / 16) * 16, 16, 16)

    -- PALETTE SELECTOR
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", love.graphics.getWidth() - ferrous.padding - (16 * 4) - 2,
        love.graphics.getHeight() - 350 - 2, 16 * 4 + 4, 20 * 4)
    love.graphics.print("use [ and ]", love.graphics.getWidth() - ferrous.padding - (16 * 4) - 2,
        love.graphics.getHeight() - 350 - 20)
    for i, pal in pairs(ferrous.palettes) do
        if i - 1 == ferrous.selectedPalette then
            love.graphics.draw(ferrous.selectedPaletteSprite,
                love.graphics.getWidth() - ferrous.padding - (16 * 4) - 20,
                love.graphics.getHeight() - 350 + 20 * (i - 1))
        end

        for j, color in pairs(pal) do
            love.graphics.setColor(color)
            love.graphics.rectangle("fill", love.graphics.getWidth() - ferrous.padding - (16 * 4) + 16 * (j - 1),
                love.graphics.getHeight() - 350 + 20 * (i - 1), 16, 16)
        end
    end
    love.graphics.setColor(1, 1, 1, 1)

    -- print(ferrous.camera:toWorld(love.mouse.getX(), love.mouse.getY()))
end

function love.mousepressed(x, y, button)
    for _, v in pairs(UiComp.static.all) do
        if v:mousepressed(x, y) then
            return
        end
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
    for _, v in pairs(UiComp.static.all) do
        if v:keypressed(key) then
            return
        end
    end

    if key == "]" then
        ferrous.selectedPalette = ferrous.selectedPalette + 1
    elseif key == "[" then
        ferrous.selectedPalette = ferrous.selectedPalette - 1
    end
    ferrous.selectedPalette = ferrous.selectedPalette % 4
end

function love.quit()
end
