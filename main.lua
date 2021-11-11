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

--https://www.gameart2d.com/winter-platformer-game-tileset.html

require "player"
require "helicopter"
require "objects"

camera = require("libraries/camera")
anim8 = require("libraries/anim8")
sti = require("libraries/Simple-Tiled-Implementation-master/sti")

local font = love.graphics.newFont(20)
love.graphics.setFont(font)

function Lerp(a, b, t)
	return a + (b - a) * t
end

function love.load(arg)
    math.randomseed(os.time())

    io.stdout:setvbuf("no")
    if arg[#arg] == "-debug" then require("mobdebug").start() end

    print("Started")

    love.window.setMode(1920, 1080, {fullscreen=false, vsync=true})
    love.window.maximize()
    centerX = love.graphics.getWidth()/2
    centerY = love.graphics.getHeight()/2
    love.graphics.setDefaultFilter("nearest", "nearest")

    cam = camera()

    --set physics meter to 64 pixels
    love.physics.setMeter(64)
    --make the physics world
    world = love.physics.newWorld(0, 9.81*64, true)
    
    CreateTerrain(0,0)

    Player:CreateBoard()
    Player:CreateParticles()
    Player:CreatePlayerAnim(0, 0)

    Heli:CreateHeliAnim(0, 0)
    Heli.anim.x , Heli.anim.y = Player:GetPos()

    background = sti("assets/bg_tilemap.lua", 0, 0)
end

function love.keypressed(key, scancode, isrepeat)
    --if R is pressed, reset
    if key == "r" then
        Player:Reset()
        Heli:Reset(Player:GetPos())
        ResetTerrain()
    end
end

function love.update(dt)
    UpdateGame(dt)
end

function UpdateGame(dt)
    --update the physics world
    world:update(dt)

    local newHeliX = Lerp(Heli.anim.x, Player.x, dt * 2)
    local newHeliY = Lerp(Heli.anim.y, Player.y - 400, dt * 2)
    local newHeliAngle =  (newHeliX - Heli.anim.x) / 20
    Heli.angle = Lerp(Heli.angle, newHeliAngle, dt * 10)
    Heli.anim.x = newHeliX
    Heli.anim.y = newHeliY
    Heli.anim.walkGridAnimation:update(dt)

    --update player
    Player:Update(dt)

    --generate new terrain if the player is near the edge of the screen
    if physicsObjects.terrain.lastPointX < Player.board.body:getX() + love.graphics.getWidth() then
        --if old terrain exists, destroy it
        if physicsObjects.oldTerrain ~= nil and physicsObjects.oldTerrain.body ~= nil then
            physicsObjects.oldTerrain.body:destroy()
        end

        physicsObjects.oldTerrain = physicsObjects.terrain

        --create a new terrain
        CreateTerrain(physicsObjects.terrain.lastPointX, physicsObjects.terrain.lastPointY)
    end

    --follow the player with the camera
    cam:lookAt(Player.board.body:getX(), Player.board.body:getY())
    --calculate how fast the player is moving compared to the maxVel
    local speed = Player.board.body:getLinearVelocity()
    local speedPercent = speed/Player.maxVel
    --set the camera zoom based on the speed of the player
    local newZoom = 1.25 - (speedPercent)/2
    cam:zoomTo(Lerp(cam.scale, newZoom, dt))

    background:update(dt)
end

function love.draw()
    DrawGame()
end

function DrawGame()
    --make the background light blue
    love.graphics.setColor(0, 0.0, 0.1)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    DrawBackground()

    --draw the terrain
    physicsObjects.terrain:Draw()

    --draw the oldTerrain (if it exists)
    if physicsObjects.oldTerrain ~= nil then
        physicsObjects.oldTerrain:Draw()
    end

    cam:attach()
    love.graphics.setColor(1, 1, 1)
    Heli.anim.walkGridAnimation:draw(Heli.anim.walkSheet, Heli.anim.x, Heli.anim.y, Heli.angle, 1.0, 1.0, Heli.anim.width/2, Heli.anim.height/2)
    cam:detach()

    Player:Draw()
    

    DrawGameUI()
end

function DrawBackground()
    love.graphics.setColor(1, 1, 1)
    local scale = 0.33
    local width = 128 * 100

    love.graphics.scale(scale, scale)

    --draw first background
    local tx = -math.fmod(Player:GetPos(), width);
    love.graphics.translate(tx, 0)
    background:drawLayer(background.layers[1])
    love.graphics.translate(-tx, 0)

    --draw second background to the right of the first
    love.graphics.translate(tx + width, 0)
    background:drawLayer(background.layers[1])
    love.graphics.translate(-tx -width, 0)

    love.graphics.scale(1/scale, 1/scale)
end

function DrawGameUI()
    --draw Player.flips at the top middle of the screen
    love.graphics.setColor(1, 1, 1)
    love.graphics.setNewFont(50);
    love.graphics.printf("FLIPS\n" .. Player.flips, 0, 50, 1920, "center")
    love.graphics.setNewFont(20);

    --draw the FPS
    love.graphics.setColor(0, 0, 0)
    love.graphics.print("FPS: "..tostring(love.timer.getFPS()), 10, 10)
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("FPS: "..tostring(love.timer.getFPS()), 9, 9)
end