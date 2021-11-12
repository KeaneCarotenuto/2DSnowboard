-- Bachelor of Software Engineering
-- Media Design School
-- Auckland
-- New Zealand
--
-- (c) 2021 Media Design School
--
-- File Name   : main.lua
-- Description : The main file resposnible for the game logic
-- Author      : Keane Carotenuto
-- Mail        : KeaneCarotenuto@gmail.com

Heli = {
    anim = nil,
    angle = 0,
    sound = nil,
}

--Create helicopter animation
function Heli:CreateHeliAnim(x,y)
    local animation = {}
    animation.x = x
    animation.y = y
    animation.walkSheet = love.graphics.newImage('assets/heli_anim.png')
    animation.imageDimension = {animation.walkSheet:getDimensions()}
    animation.width = 1800/6
    animation.height = 144
    animation.walkGrid = anim8.newGrid(animation.width, animation.height, animation.imageDimension[1], animation.imageDimension[2])
    animation.walkGridAnimation = anim8.newAnimation(animation.walkGrid('1-6', 1), 0.01)
  
    Heli.anim = animation
end

--Helicopter update function
function Heli:Update(dt)
    local oldHeliX = Heli.anim.x
    local oldHeliY = Heli.anim.y
    local newHeliX = Player.x 
    local newHeliY = Player.y - 400
    newHeliX = Lerp(oldHeliX, newHeliX, dt * 2)
    newHeliY = Lerp(oldHeliY, newHeliY, dt * 2)

    local vx, xy = Player.board.body:getLinearVelocity()

    local newAngle = Lerp(0, 45, vx / Player.maxVel)

    Heli.angle = math.rad(newAngle)
    Heli.anim.x = newHeliX
    Heli.anim.y = newHeliY
    Heli.anim.walkGridAnimation:update(dt)

    --update the sound of the helicopter based on the distance to camera
    local distance = math.sqrt((Heli.anim.x - cam.x)^2 + (Heli.anim.y - cam.y)^2)
    Heli.sound:setVolume(Clamp((1000 / distance) / 5, 0.0, 0.15))
end

function Heli:Draw()
    cam:attach()
    love.graphics.setColor(1, 1, 1)
    Heli.anim.walkGridAnimation:draw(Heli.anim.walkSheet, Heli.anim.x, Heli.anim.y, Heli.angle, 1.0, 1.0, Heli.anim.width/2, Heli.anim.height/2)
    cam:detach()
end

function Heli:Reset(x,y)
    Heli.angle = 0
    Heli.anim.x = x
    Heli.anim.y = y
end

return Heli