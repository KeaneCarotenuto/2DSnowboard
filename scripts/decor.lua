-- Bachelor of Software Engineering
-- Media Design School
-- Auckland
-- New Zealand
--
-- (c) 2021 Media Design School
--
-- File Name   : decor.lua
-- Description : Inheritance example, creates decor objects
-- Author      : Keane Carotenuto
-- Mail        : KeaneCarotenuto@gmail.com

--create a base decor class
decor = {}
decor.__index = decor

DecorType = {
    Rock = 1,
    Tree = 2,
    Bush = 3,
    Cloud = 4,
}

--initialize the decor
function decor.new(x, y, type, name)
    local self = setmetatable({}, decor)
    self.x = x
    self.y = y
    self.type = type
    self.name = name

    --add to decor list
    table.insert(decorList, self)

    return self
end

--delete and remove from list
function decor:Delete()
    --remove from decor list
    for i, v in ipairs(decorList) do
        if v == self then
            table.remove(decorList, i)
        end
    end

    --set all values to nil
    for k, v in pairs(self) do
        self[k] = nil
    end

    --delete the decor
    setmetatable(self, nil)
end

--draw the decor
function decor:Draw()
    cam:attach()
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(self.name .. ", " .. self.type, self.x, self.y, 1920, "left")
    cam:detach()
end

function decor:Update(dt)
    --if x position is to the left of the camera, delete the decor
    if self.x < cam.x - love.graphics.getWidth() * cam.scale then
        self:Delete()
    end
end

--cloud child
cloud = {}
cloud.__index = cloud

--initialize cloud
function cloud.new(x, name)
    local self = setmetatable({}, cloud)

    local randX = x + math.random(love.graphics.getWidth(), love.graphics.getWidth() * 2)
    local nx, ny = GetNearest(randX, 0)
    local randY = ny - math.random(love.graphics.getHeight() / 2, love.graphics.getHeight())

    self.x = randX
    self.y = randY
    self.type = DecorType.Cloud
    self.name = name
    self.image = love.graphics.newImage("assets/cloud.png")
    self.shade = math.random(0.7, 1.0)

    --add to decor list
    table.insert(decorList, self)

    return self
end

setmetatable(cloud, {__index = decor})

--draw the cloud
function cloud:Draw()
    cam:attach()
    love.graphics.setColor(self.shade, self.shade, self.shade)
    love.graphics.draw(self.image, self.x, self.y)
    cam:detach()
end

--rock child
rock = {}
rock.__index = rock

--initialize rock
function rock.new(x, name, imagePath)
    local self = setmetatable({}, rock)

    local randX = x + math.random(love.graphics.getWidth(), love.graphics.getWidth() * 2)
    local nx, ny = GetNearest(randX, 0)
    local randY = ny + math.random(love.graphics.getHeight() / 2, love.graphics.getHeight())

    self.x = randX
    self.y = randY
    self.type = DecorType.Rock
    self.name = name
    self.image = love.graphics.newImage(imagePath)
    self.shade = math.random(0.4, 0.9)

    --add to decor list
    table.insert(decorList, self)

    return self
end

setmetatable(rock, {__index = decor})

--draw the rock
function rock:Draw()
    cam:attach()
    love.graphics.setColor(self.shade, self.shade, self.shade)
    love.graphics.draw(self.image, self.x, self.y)
    cam:detach()
end


--list of all decor
decorList = {}

local randCloudTimer = 0
local randRockTimer = 0
function UpdateDecor(dt)
    --create new clouds if needed
    if randCloudTimer > 0 then
        randCloudTimer = randCloudTimer - dt
    else
        randCloudTimer = math.random(5, 10)
        
        local newcloud = cloud.new(Player.x, "Cloud1")
    end

    --create new rocks 
    if randRockTimer > 0 then
        randRockTimer = randRockTimer - dt
    else
        randRockTimer = math.random(0.0, 1.0)
        
        local newrock = rock.new(Player.x, "Rock1", "assets/rocks/" .. math.random(1,7) .. ".png")
    end

    --update all decor
    for i,v in ipairs(decorList) do
        v:Update(dt)
    end

end