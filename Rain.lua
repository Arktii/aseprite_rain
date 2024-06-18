-- "Constants"
local DEFAULT_FRAMES = 20
local DEFAULT_LAYERS = 2

local DEFAULT_COLOR = app.pixelColor.rgba(149, 192, 194, 156)
local DEFAULT_RAINDROP_LENGTH = 15
local DEFAULT_ANGLE = 0
local DEFAULT_SPEED = 25.0 -- pixels per frame

local DEFAULT_SPAWNRATE = 12
local DEFAULT_RANDOM_LENGTH_NEG = -10
local DEFAULT_RANDOM_LENGTH_POS = 10
local DEFAULT_RANDOM_ANGLE = "0°"

local OPACITY_CHANGE = 0.6
local DROP_HEIGHT = 20
local MAX_ANGLE = 45 -- from y-axis

-- Globals
local sprite = app.activeSprite
local raindrops = {}
-- bounds
local bound_left = 0 
local bound_right = sprite.width
local bound_top = sprite.height - DROP_HEIGHT
local bound_bottom = sprite.height + DEFAULT_RAINDROP_LENGTH

-- Dialog Setup
local dlg = Dialog {title = "Rain"}

dlg:number{
    id = "frames",
    label = "Frames",
    text = tostring(DEFAULT_FRAMES),
    decimals = 0,
    onchange = function() limitMin("frames", 0) end
}

dlg:number{
    id = "layers",
    label = "Layers",
    text = tostring(DEFAULT_LAYERS),
    decimals = 0,
    onchange = function() limitMin("layers", 0) end
}

-- Presets
dlg:combobox{ 
    id = "presets",
    label = "Preset",
    option = "Default",
    options = { "Default", "Drizzle", "Rainstorm", "Monsoon", "Windy" },
    onchange = function()
        local option = dlg.data["presets"]
        if option == "Default" then
            dlg:modify{id = "drop_length", text = DEFAULT_RAINDROP_LENGTH}
            dlg:modify{id = "aa", selected = false}
            dlg:modify{id = "speed", text = DEFAULT_SPEED}
            dlg:modify{id = "angle", text = DEFAULT_ANGLE}
            dlg:modify{id = "spawnrate", text = DEFAULT_SPAWNRATE}
            dlg:modify{id = "rand_length_neg", text = DEFAULT_RANDOM_LENGTH_NEG}
            dlg:modify{id = "rand_length_pos", text = DEFAULT_RANDOM_LENGTH_POS}
            dlg:modify{id = "rand_angle_neg", text = DEFAULT_RANDOM_ANGLE}
            dlg:modify{id = "rand_angle_pos", text = DEFAULT_RANDOM_ANGLE}
        elseif option == "Drizzle" then
            dlg:modify{id = "drop_length", text = scaleToSpriteHeight(8)}
            dlg:modify{id = "aa", selected = false}
            dlg:modify{id = "speed", text = scaleToSpriteHeight(DEFAULT_SPEED)}
            dlg:modify{id = "angle", text = 0}
            dlg:modify{id = "spawnrate", text = scaleToSpriteWidth(6)}
            dlg:modify{id = "rand_length_neg", text = scaleToSpriteHeight(-5)}
            dlg:modify{id = "rand_length_pos", text = scaleToSpriteHeight(5)}
            dlg:modify{id = "rand_angle_neg", text = 0}
            dlg:modify{id = "rand_angle_pos", text = 0}
        elseif option == "Rainstorm" then
            dlg:modify{id = "drop_length", text = scaleToSpriteHeight(DEFAULT_RAINDROP_LENGTH)}
            dlg:modify{id = "aa", selected = false}
            dlg:modify{id = "speed", text = scaleToSpriteHeight(DEFAULT_SPEED)}
            dlg:modify{id = "angle", text = DEFAULT_ANGLE}
            dlg:modify{id = "spawnrate", text = scaleToSpriteWidth(DEFAULT_SPAWNRATE)}
            dlg:modify{id = "rand_length_neg", text = scaleToSpriteHeight(DEFAULT_RANDOM_LENGTH_NEG)}
            dlg:modify{id = "rand_length_pos", text = scaleToSpriteHeight(DEFAULT_RANDOM_LENGTH_POS)}
            dlg:modify{id = "rand_angle_neg", text = 0}
            dlg:modify{id = "rand_angle_pos", text = 0}
        elseif option == "Monsoon" then
            dlg:modify{id = "drop_length", text = scaleToSpriteHeight(20)}
            dlg:modify{id = "aa", selected = false}
            dlg:modify{id = "speed", text = scaleToSpriteHeight(30)}
            dlg:modify{id = "angle", text = 25}
            dlg:modify{id = "spawnrate", text = scaleToSpriteWidth(30)}
            dlg:modify{id = "rand_length_neg", text = scaleToSpriteHeight(-12)}
            dlg:modify{id = "rand_length_pos", text = scaleToSpriteHeight(15)}
            dlg:modify{id = "rand_angle_neg", text = -2.5}
            dlg:modify{id = "rand_angle_pos", text = 7.5}
        elseif option == "Windy" then
            dlg:modify{id = "drop_length", text = scaleToSpriteHeight(DEFAULT_RAINDROP_LENGTH)}
            dlg:modify{id = "aa", text = false}
            dlg:modify{id = "speed", text = scaleToSpriteHeight(35)}
            dlg:modify{id = "angle", text = 45}
            dlg:modify{id = "spawnrate", text = scaleToSpriteWidth(DEFAULT_SPAWNRATE)}
            dlg:modify{id = "rand_length_neg", text = scaleToSpriteHeight(DEFAULT_RANDOM_LENGTH_NEG)}
            dlg:modify{id = "rand_length_pos", text = scaleToSpriteHeight(DEFAULT_RANDOM_LENGTH_POS)}
            dlg:modify{id = "rand_angle_neg", text = 0}
            dlg:modify{id = "rand_angle_pos", text = 0}
        else
            return
        end

        updateYBounds()
        updateXBounds()
    end
}

-- Preset values are calculated based on 128 x 96 (width x height)
-- Calculate the value with respect to any sprite size
function scaleToSpriteWidth(x) 
    return math.ceil( x / 128 * sprite.width )
end

function scaleToSpriteHeight(y)
    return math.ceil( y / 96 * sprite.height )
end

-- Drop customization
dlg:separator{id = "drop_look", text = "Drop Appearance"}

dlg:color{
    id = "color", 
    label = "Raindrop Color: ", 
    color = DEFAULT_COLOR,
}

dlg:number{
    id = "drop_length",
    label = "Drop Length",
    text = tostring(DEFAULT_RAINDROP_LENGTH),
    decimals = 0,
    onchange = function() 
        limitMin("drop_length", 1) 
        updateYBounds()
        updateXBounds()
    end
}

dlg:check{
    id = "aa", 
    label = "Anti-Aliasing", 
    selected = false,
}

-- Movement
dlg:separator{id = "movement_group", text = "Movement"}

dlg:number{
    id = "speed",
    label = "Speed and Angle",
    text = tostring(DEFAULT_SPEED),
    decimals = 1,
    onchange = function()
        limitMin("speed", 1)
    end
}

dlg:number{
    id = "angle",
    text = "0°",
    decimals = 1,
    onchange = function()
        clamp("angle", -MAX_ANGLE, MAX_ANGLE)
        updateXBounds()
    end
}

function updateYBounds()
    bound_bottom = sprite.height + dlg.data.drop_length
end

function updateXBounds()
    local angle = dlg.data.angle 
    if angle > 0 then
        bound_left = -(sprite.height + math.abs(bound_top)) * math.tan(math.rad(dlg.data.angle))
        bound_right = sprite.width + dlg.data.drop_length;
    elseif angle < 0 then
        bound_left = -dlg.data.drop_length
        bound_right = sprite.width + (sprite.height + math.abs(bound_top)) * math.tan(math.rad(math.abs(dlg.data.angle)))
    end
end

-- Spawning
dlg:separator{id = "spawn_group", text = "Drop Spawning"}

dlg:number{
    id = "spawnrate",
    label = "Drop Spawn Rate",
    text = tostring(10),
    decimals = 0,
    onchange = function() 
        limitMin("spawnrate", 1)
    end
}

dlg:separator{id = "randomness", text = "Randomness"}

dlg:number{
    id = "rand_length_neg",
    label = "Length Randomness",
    text = tostring(DEFAULT_RANDOM_LENGTH_NEG),
    decimals = 0,
    onchange = function() 
        clamp("rand_length_neg", -dlg.data.drop_length, 0)
    end
}

dlg:number{
    id = "rand_length_pos",
    text = tostring(DEFAULT_RANDOM_LENGTH_POS),
    decimals = 0,
    onchange = function() 
        limitMin("rand_length_pos", 0)
    end
}

dlg:number{
    id = "rand_angle_neg",
    label = "Angle Randomness",
    text = DEFAULT_RANDOM_ANGLE,
    decimals = 1,
    onchange = function()
        clamp("rand_angle_neg", -15, 0)
    end
}

dlg:number{
    id = "rand_angle_pos",
    text = DEFAULT_RANDOM_ANGLE,
    decimals = 1,
    onchange = function()
        clamp("rand_angle_pos", 0, 15)
    end
}

-- this can feel buggy for numbers greater than 1
function limitMin(id, min)
    if dlg.data[id] < min then dlg:modify{id = id, text = tostring(min)} end
end

function clamp(id, min, max)
    if dlg.data[id] < min then
        dlg:modify{id = id, text = tostring(min)}
    elseif dlg.data[id] > max then
        dlg:modify{id = id, text = tostring(max)}
    end
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
    for layerIndex = 1, dlg.data.layers do
        table.insert(raindrops, {})
        -- spawn drops
        for _ = 1, dlg.data.spawnrate * 5 do createDrop(layerIndex) end
        -- simulate one full cycle
        for _ = 1, dlg.data.frames do updateDrops(layerIndex) end
    end
end

function updateDrops(index)
    -- spawn drops
    for i = 1, dlg.data.spawnrate do createDrop(index) end
    -- iterate backwards to not bug out when removing elements
    for i = #raindrops[index], 1, -1 do
        local raindrop = raindrops[index][i]
        raindrop:move()

        if (raindrop.y > bound_bottom or raindrop.x > bound_right or raindrop.x < bound_left) then
            table.remove(raindrops[index], i)
        end
    end
end

function createDrop(index, x, y)
    x = x or math.random(bound_left, bound_right)
    y = y or math.random(-bound_top, 0)

    length = dlg.data.drop_length
    -- length cannot be 0
    length = math.max(1, math.random(length + dlg.data.rand_length_neg,
                                     length + dlg.data.rand_length_pos))

    local new_angle = math.random(dlg.data.angle + dlg.data.rand_angle_neg, dlg.data.angle + dlg.data.rand_angle_pos)

    local velocity_x = dlg.data.speed * math.sin(math.rad(new_angle))
    local velocity_y = dlg.data.speed * math.cos(math.rad(new_angle))

    local drop = Raindrop:new(x, y, velocity_x, velocity_y, length)
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

    if dlg.data.aa then
        drawAALine(x0, y0, self.x, self.y, function(x, y, opacity)
            plot(image, x, y, opacity * opacityMultiplier)
        end)
    else
        drawLine(x0, y0, self.x, self.y,
                 function(x, y) plot(image, x, y, opacityMultiplier) end)
    end
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
function drawAALine(x0, y0, x1, y1, plotFunction)
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
        plotFunction(ypxl1 + 1, xpxl1, fpart(yend) * xgap)
    else
        plotFunction(xpxl1, ypxl1 + 1, fpart(yend) * xgap)
    end

    local intery = yend + gradient

    -- handle second endpoint
    xend = round(x1)
    yend = y1 + gradient * (xend - x1)
    xgap = fpart(x1 + 0.5)
    local xpxl2 = xend
    local ypxl2 = ipart(yend)

    if steep then
        plotFunction(ypxl2 + 1, xpxl2, fpart(yend) * xgap)
    else
        plotFunction(xpxl2, ypxl2 + 1, fpart(yend) * xgap)
    end

    if steep then
        for x = xpxl1 + 1, xpxl2 - 1 do
            plotFunction(ipart(intery), x, rfpart(intery))
            plotFunction(ipart(intery) + 1, x, fpart(intery))
            intery = intery + gradient
        end
    else
        for x = xpxl1 + 1, xpxl2 - 1 do
            plotFunction(x, ipart(intery), rfpart(intery))
            plotFunction(x, ipart(intery) + 1, fpart(intery))
            intery = intery + gradient
        end
    end
end

-- function to draw a line with Bresenham's line algorithm
-- https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm
function drawLine(x0, y0, x1, y1, plotFunction)
    x0 = math.floor(x0)
    y0 = math.floor(y0)
    x1 = math.floor(x1)
    y1 = math.floor(y1)
    -- difference
    local dx = math.abs(x1 - x0)
    local dy = -math.abs(y1 - y0)
    -- step
    local sx = x0 < x1 and 1 or -1
    local sy = y0 < y1 and 1 or -1
    -- error
    local err = dx + dy

    while true do
        plotFunction(x0, y0)
        if x0 == x1 and y0 == y1 then break end
        local e2 = 2 * err
        if e2 >= dy then
            if x0 == x1 then break end
            err = err + dy
            x0 = x0 + sx
        end
        if e2 <= dx then
            if y0 == y1 then break end
            err = err + dx
            y0 = y0 + sy
        end
    end
end
