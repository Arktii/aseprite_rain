-- "Constants"
local DEFAULT_FRAMES = 25
local DEFAULT_LAYERS = 3
local OPACITY_CHANGE = 0.65

local DEFAULT_COLOR = app.fgColor
local DEFAULT_RAINDROP_LENGTH = 15
local DEFAULT_SPEED = 35.0 -- pixels per frame

local DEFAULT_SPAWNRATE = 10
local DEFAULT_RANDOM_LENGTH = 10

local MAX_OUT_OF_CANVAS = 20

-- Globals
local sprite = app.activeSprite
local raindrops = {}
local boundX = sprite.width * 1.5;
local boundY = sprite.height;

-- Dialog Setup
local dlg = Dialog {title = "Rain"}

dlg:number{
    id = "frames",
    label = "Frames",
    text = tostring(DEFAULT_FRAMES),
    decimals = 0,
    onchange = function() ensureMinZero("frames") end
}

dlg:number{
    id = "layers",
    label = "Layers",
    text = tostring(DEFAULT_LAYERS),
    decimals = 0,
    onchange = function() ensureMinZero("layers") end
}

dlg:separator{id = "drop_look", text = "Drop Appearance"}

dlg:color{id = "color", label = "Outline Color: ", color = DEFAULT_COLOR}

dlg:number{
    id = "drop_length",
    label = "Drop Length",
    text = tostring(DEFAULT_RAINDROP_LENGTH),
    decimals = 0,
    onchange = function() ensureMinZero("drop_length") end
}

dlg:separator{id = "movement_group", text = "Movement"}

dlg:number{
    id = "speedX",
    label = "Velocity",
    text = tostring(0),
    decimals = 1,
    hexpand = false,
    onchange = function()
        updateAngle()
        updateSpeed()
    end
}

dlg:number{
    id = "speedY",
    text = tostring(DEFAULT_SPEED),
    decimals = 1,
    hexpand = false,
    onchange = function()
        updateAngle()
        updateSpeed()
    end
}

dlg:number{
    id = "speed",
    label = "Speed and Angle",
    text = tostring(DEFAULT_SPEED),
    decimals = 1,
    hexpand = false,
    onchange = function() updateComponents() end
}

dlg:number{
    id = "angle",
    text = "0°",
    decimals = 1,
    hexpand = false,
    onchange = function() updateComponents() end
}

-- with respect to y-axis
function updateAngle()
    local angle = 90
    if dlg.data.speedY ~= 0 then
        angle = math.deg(math.atan(dlg.data.speedX / dlg.data.speedY))
    end
    dlg:modify{id = "angle", text = string.format("%.2f°", angle)}
end

function updateSpeed()
    local speed = math.sqrt(
                      dlg.data.speedX * dlg.data.speedX + dlg.data.speedY *
                          dlg.data.speedY)
    dlg:modify{id = "speed", text = string.format("%.2f", speed)}
end

function updateComponents()
    local x = dlg.data.speed * math.sin(math.rad(dlg.data.angle))
    local y = dlg.data.speed * math.cos(math.rad(dlg.data.angle))

    dlg:modify{id = "speedX", text = string.format("%.2f", x)}
    dlg:modify{id = "speedY", text = string.format("%.2f", y)}

end

dlg:separator{id = "spawn_group", text = "Drop Spawning"}

dlg:number{
    id = "spawnrate",
    label = "Drop Spawn Rate",
    text = tostring(10),
    decimals = 0,
    onchange = function() ensureMinZero("spawnrate") end
}

dlg:separator{id = "randomness", text = "Randomness"}

dlg:number{
    id = "rand_length",
    label = "Length",
    text = tostring(DEFAULT_RANDOM_LENGTH),
    decimals = 0,
    onchange = function() ensureMinZero("rand_length") end
}

function ensureMinZero(id)
    if dlg.data[id] < 0 then dlg:modify{id = id, text = "0"} end

end

dlg:button{id = "run", text = "RUN", onclick = function() run() end}

dlg:button{id = "close", text = "CLOSE", onclick = function() dlg:close() end}

dlg:show{wait = false}

function run()
    sprite = app.activeSprite
    local rows = sprite.height
    local cols = sprite.width

    local layers = {}

    for i = 1, dlg.data.layers do
        app.command.NewLayer {name = "Rain " .. tostring(i), top = true}
        table.insert(layers, app.activeLayer)
    end

    initializeDrops()

    for layerIndex = 1, dlg.data.layers do
        for frameNum = 1, dlg.data.frames do
            updateDrops(layerIndex)

            local image = Image(sprite.width, sprite.height)

            drawDrops(layerIndex, image)

            if frameNum > #sprite.frames then app.command.NewFrame {} end
            sprite:newCel(layers[layerIndex], frameNum, image)
        end
    end
end

function initializeDrops()
    raindrops = {}
    local halfpoint = math.floor(dlg.data.frames / 2)
    for layerIndex = 1, dlg.data.layers do
        table.insert(raindrops, {})
        -- spawn drops
        for _ = 1, dlg.data.spawnrate * 5 do
            createDrop(layerIndex)
        end
        -- simulate until halfpoint
        for _ = 1, halfpoint do
            updateDrops(layerIndex)
        end
    end
end

function updateDrops(index)
    -- spawn drops
    for i = 1, dlg.data.spawnrate do createDrop(index) end
    -- iterate backwards to not bug out when removing elements
    for i = #raindrops[index], 1, -1 do
        local raindrop = raindrops[index][i]
        raindrop:move()

        if (raindrop.y > sprite.height + MAX_OUT_OF_CANVAS) then
            table.remove(raindrops[index], i)
        end
    end
end

function createDrop(index, x, y)
    x = x or math.random(-MAX_OUT_OF_CANVAS, sprite.width + MAX_OUT_OF_CANVAS)
    y = y or math.random(-MAX_OUT_OF_CANVAS, 0)

    length = dlg.data.drop_length
    -- length cannot be 0
    length = math.max(1, math.random(length - dlg.data.rand_length,
                                     length + dlg.data.rand_length))
    local drop = Raindrop:new(x, y, dlg.data.speedX, dlg.data.speedY, length)
    table.insert(raindrops[index], drop)

    return drop
end

function drawDrops(layerIndex, image)
    for _, drop in pairs(raindrops[layerIndex]) do
        drop:draw(layerIndex, image)
    end
end

-- "Classes"
Raindrop = {
    x = 0,
    y = 0,
    length = DEFAULT_RAINDROP_LENGTH,
    __velocity_x = 0,
    __velocity_y = DEFAULT_SPEED,
    __speed,
    __dirX,
    __dirY
}

function Raindrop:new(x, y, velocity_x, velocity_y, length)
    obj = {}
    setmetatable(obj, self)
    self.__index = self
    obj.x = x
    obj.y = y
    obj.length = length
    obj.__velocity_x = velocity_x
    obj.__velocity_y = velocity_y

    -- Calculating magnitude and direction for performance reasons
    obj.__speed = math.sqrt(obj.__velocity_x * obj.__velocity_x +
                                obj.__velocity_y * obj.__velocity_y)
    obj.__dirX = velocity_x / obj.__speed
    obj.__dirY = velocity_y / obj.__speed

    return obj
end

-- update to next position
function Raindrop:move(frames_passed)
    frames_passed = frames_passed or 1
    self.x = self.x + (self.__velocity_x * frames_passed)
    self.y = self.y + (self.__velocity_y * frames_passed)
end

function Raindrop:draw(layerIndex, image)
    local tailDirX = -self.__dirX
    local tailDirY = -self.__dirY

    local x0 = self.x + tailDirX * self.length
    local y0 = self.y + tailDirY * self.length

    local opacityMultiplier = OPACITY_CHANGE ^ (layerIndex - 1)

    drawLine(image, x0, y0, self.x, self.y, function(image, x, y, opacity)
        plot(image, x, y, opacity * opacityMultiplier)
    end)
end

-- Function to plot a pixel with a specific opacity (0.0 to 1.0)
function plot(image, x, y, opacity)
    local color = app.pixelColor.rgba(dlg.data.color.red, dlg.data.color.green,
                                      dlg.data.color.blue,
                                      dlg.data.color.alpha * opacity)
    image:drawPixel(x, y, color)
end

-- Function to draw a line using Xiaolin Wu's algorithm
-- https://en.wikipedia.org/wiki/Xiaolin_Wu%27s_line_algorithm
function drawLine(image, x0, y0, x1, y1, plotFunction)
    local function ipart(x) return math.floor(x) end -- integer part
    local function round(x) return math.floor(x + 0.5) end -- rounded integer part
    local function fpart(x) return x - math.floor(x) end -- fractional part
    local function rfpart(x) return 1 - fpart(x) end -- reverse fractional part

    -- steep if change in y greater than x
    local steep = math.abs(y1 - y0) > math.abs(x1 - x0)
    if steep then
        x0, y0 = y0, x0 -- swap
        x1, y1 = y1, x1 -- swap
    end

    if x0 > x1 then
        x0, x1 = x1, x0 -- swap
        y0, y1 = y1, y0 -- swap
    end

    -- difference
    local dx = x1 - x0
    local dy = y1 - y0
    local gradient = dy / dx

    -- handle first end point
    local xend = round(x0)
    local yend = y0 + gradient * (xend - x0)
    local xgap = rfpart(x0 + 0.5)
    local xpxl1 = xend
    local ypxl1 = ipart(yend)

    if steep then
        -- plot(image, ypxl1, xpxl1, rfpart(yend) * xgap)
        plotFunction(image, ypxl1 + 1, xpxl1, fpart(yend) * xgap)
    else
        -- plot(image, xpxl1, ypxl1, rfpart(yend) * xgap)
        plotFunction(image, xpxl1, ypxl1 + 1, fpart(yend) * xgap)
    end

    local intery = yend + gradient

    -- handle second endpoint
    xend = round(x1)
    yend = y1 + gradient * (xend - x1)
    xgap = fpart(x1 + 0.5)
    local xpxl2 = xend
    local ypxl2 = ipart(yend)

    if steep then
        -- plot(image, ypxl2, xpxl2, rfpart(yend) * xgap)
        plotFunction(image, ypxl2 + 1, xpxl2, fpart(yend) * xgap)
    else
        -- plot(image, xpxl2, ypxl2, rfpart(yend) * xgap)
        plotFunction(image, xpxl2, ypxl2 + 1, fpart(yend) * xgap)
    end

    if steep then
        for x = xpxl1 + 1, xpxl2 - 1 do
            plotFunction(image, ipart(intery), x, rfpart(intery))
            plotFunction(image, ipart(intery) + 1, x, fpart(intery))
            intery = intery + gradient
        end
    else
        for x = xpxl1 + 1, xpxl2 - 1 do
            plotFunction(image, x, ipart(intery), rfpart(intery))
            plotFunction(image, x, ipart(intery) + 1, fpart(intery))
            intery = intery + gradient
        end
    end
end
