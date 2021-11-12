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

--1 = menu, 2 = game, 3 = game over
Scenes = {
    menu = 1,
    game = 2,
    gameOver = 3
}
CurrentScene = Scenes.menu
NextScene = Scenes.menu

Fade = 1
FadeSpeed = -1

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

    bgImage = love.graphics.newImage("assets/bg_image.png")
    bgDeath = love.graphics.newImage("assets/bg_death.png")

    --create and start music
    music = love.audio.newSource("assets/music.wav", "stream")
    music:setLooping(true)
    music:setVolume(0.05)
    music:play()

    --create and start heli sound
    heliSound = love.audio.newSource("assets/heli.wav", "static")
    heliSound:setLooping(true)
    heliSound:setVolume(0.15)
end

function love.keypressed(key, scancode, isrepeat)
    if CurrentScene == Scenes.menu then
        if key == "space" then
            StartFade(1)
            NextScene = Scenes.game
        end

        if key == "escape" then
            love.event.quit()
        end

    elseif CurrentScene == Scenes.game then
        --if R is pressed, reset
        if key == "r" then
            StartFade(1)
            NextScene = Scenes.game
        end

        --if escape is pressed, go to menu
        if key == "escape" then
            StartFade(1)
            NextScene = Scenes.menu
        end

    elseif CurrentScene == Scenes.gameOver then
        if key == "r" then
            StartFade(1)
            NextScene = Scenes.game
        end

        if key == "escape" then
            StartFade(1)
            NextScene = Scenes.menu
        end
    end
end

function love.update(dt)
    --switch case for current scene
    if CurrentScene == Scenes.menu then
        --do nothing
    elseif CurrentScene == Scenes.game then
        UpdateGame(dt)
    elseif CurrentScene == Scenes.gameOver then
        --do nothing
    end

    --update fade value
    if FadeSpeed ~= 0 then
        Fade = Fade + FadeSpeed * dt
        if Fade < 0 then
            Fade = 0
            FadeSpeed = 0
        end
        if Fade > 1 then
            Fade = 1
            FadeSpeed = 0
            FadeEnded()
        end
    end
end

function StartFade(speed)
    FadeSpeed = speed
end

function FadeEnded()
    --switch case for next scene
    if NextScene == Scenes.menu then
        CurrentScene = Scenes.menu
        Player.snowSound:stop()
        heliSound:stop()
        StartFade(-1)
    elseif NextScene == Scenes.game then
        CurrentScene = Scenes.game
        StartFade(-1)
        Reset()
    elseif NextScene == Scenes.gameOver then
        CurrentScene = Scenes.gameOver
        StartFade(-1)
        Player.snowSound:stop()
        heliSound:stop()
    end
end

function UpdateGame(dt)
    --update the physics world
    world:update(dt)

    local newHeliX = Lerp(Heli.anim.x, Player.x, dt * 2)
    local newHeliY = Lerp(Heli.anim.y, Player.y - 400, dt * 2)
    local newHeliAngle =  (newHeliX - Heli.anim.x) / 20
    newHeliAngle = Clamp(newHeliAngle, Heli.angle - 1, Heli.angle + 1)
    Heli.angle = Lerp(Heli.angle, newHeliAngle, dt * 10)
    Heli.anim.x = newHeliX
    Heli.anim.y = newHeliY
    Heli.anim.walkGridAnimation:update(dt)

    --update player
    Player:Update(dt)

    --update the sound of the helicopter based on the distance to camera
    local distance = math.sqrt((Heli.anim.x - cam.x)^2 + (Heli.anim.y - cam.y)^2)
    heliSound:setVolume(Clamp((1000 / distance) / 5, 0.0, 0.15))

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
    if Player.alive then
        cam:lookAt(Player.board.body:getX(), Player.board.body:getY())

        --calculate how fast the player is moving compared to the maxVel
        local speed = Player.board.body:getLinearVelocity()
        local speedPercent = speed/Player.maxVel
        --set the camera zoom based on the speed of the player
        local newZoom = 1.25 - (speedPercent)/2
        cam:zoomTo(Lerp(cam.scale, newZoom, dt))
    else
        local newX = Lerp(cam.x, Heli.anim.x, dt / 3)
        local newY = Lerp(cam.y, Heli.anim.y, dt / 3)
        cam:lookAt(newX, newY)

        local newZoom = Lerp(cam.scale, 0.5, dt / 3)
        cam:zoomTo(newZoom)
    end

    background:update(dt)
end

function love.draw()
    --switch case for Scenes
    if CurrentScene == Scenes.menu then
        DrawMenu()
    elseif CurrentScene == Scenes.game then
        DrawGame()
    elseif CurrentScene == Scenes.gameOver then
        DrawGameOver()
    end

    --draw the fade overlay
    if Fade > 0 then
        love.graphics.setColor(0, 0, 0, Fade)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    end
end

function DrawMenu()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(bgImage, 0, 0)
end

function DrawGame()
    --make the background dark blue
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

function DrawGameOver()
    --black screen
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    --death image
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(bgDeath, 0, 0)

    --draw Player.flips at the top middle of the screen
    love.graphics.setColor(1, 1, 1)
    love.graphics.setNewFont(60);
    love.graphics.printf("FLIPS\n" .. Player.flips, 0, 50, 1920, "center")
    love.graphics.setNewFont(20);

    --draw the game over text
    love.graphics.setColor(1, 1, 1)
    love.graphics.setNewFont(60);
    love.graphics.printf("Game Over", 0, love.graphics.getHeight()/2 - 50, love.graphics.getWidth(), "center")
    love.graphics.setNewFont(20);

    --draw the play again text
    love.graphics.setColor(1, 1, 1)
    love.graphics.setNewFont(30);
    love.graphics.printf("Press [R] to Play Again", 0, love.graphics.getHeight()/2 + 50, love.graphics.getWidth(), "center")
    love.graphics.setNewFont(20);

    --draw the quit text
    love.graphics.setColor(1, 1, 1)
    love.graphics.setNewFont(30);
    love.graphics.printf("Press [ESCAPE] to Return to Menu", 0, love.graphics.getHeight()/2 + 100, love.graphics.getWidth(), "center")
    love.graphics.setNewFont(20);

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
    love.graphics.setNewFont(60);
    love.graphics.printf("FLIPS\n" .. Player.flips, 0, 50, 1920, "center")
    love.graphics.setNewFont(20);

    --draw the FPS
    love.graphics.setColor(0, 0, 0)
    love.graphics.print("FPS: "..tostring(love.timer.getFPS()), 10, 10)
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("FPS: "..tostring(love.timer.getFPS()), 9, 9)
end

function Reset()
    world:update(1)
    Player:Reset()
    Heli:Reset(Player:GetPos())
    ResetTerrain()

    Player.snowSound:play()
    heliSound:play()
end

function Lerp(a, b, t)
	return a + (b - a) * t
end

function Clamp(min, val, max)
    return math.max(min, math.min(val, max));
end