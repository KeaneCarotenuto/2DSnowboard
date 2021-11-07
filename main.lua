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

--D:\Programs\LOVE

local font = love.graphics.newFont(20)
love.graphics.setFont(font)

local redBallRot = 0
local redBallX, redBallY = 0, 0
local localX = 0
local localY = 0
local realX = 0
local realY = 0

local isGrounded = false
local spaceHeld = false

local particleSystem

function Lerp(a, b, t)
	return a + (b - a) * t
end

function love.load(arg)
    math.randomseed(os.time())

    io.stdout:setvbuf("no")
    if arg[#arg] == "-debug" then require("mobdebug").start() end

    print("Started")

    love.window.setMode(1600, 800, {resizable=true, vsync=false, minwidth=1600, minheight=800})
    centerX = love.graphics.getWidth()/2
    centerY = love.graphics.getHeight()/2
    love.graphics.setDefaultFilter("nearest", "nearest")

    --Import camera
    camera = require("libraries/camera")
    cam = camera()

    --set physics meter to 64 pixels
    love.physics.setMeter(64)
    --make the physics world
    world = love.physics.newWorld(0, 9.81*64, true)
    --require the objects
    require("objects")



    -- Create a simple image with a single white pixel to use for the particles.
	-- We could load an image from the hard drive but this is just an example.
	local imageData = love.image.newImageData(1, 1)
	imageData:setPixel(0,0, 1,1,1,1)

	local image = love.graphics.newImage(imageData)

	-- Create and initialize the particle system object.
	particleSystem = love.graphics.newParticleSystem(image, 1000)
	particleSystem:setEmissionRate(150)
	particleSystem:setParticleLifetime(0.1, 0.5)
	particleSystem:setSizes(2)
	particleSystem:setSpread(2*math.pi)
	particleSystem:setSpeed(20, 30)
	particleSystem:setColors(1,1,1,1)
end

function love.keypressed(key, scancode, isrepeat)

end

function love.update(dt)
    --update the physics world
    world:update(dt)
    
    --If the A and D keys are pressed, apply torque to the ball to rotate it
    if love.keyboard.isDown("a") then
        physicsObjects.redBall.body:applyTorque(-100)
    end
    if love.keyboard.isDown("d") then
        physicsObjects.redBall.body:applyTorque(100)
    end

    redBallRot = physicsObjects.redBall.body:getAngle()
    redBallX, redBallY = physicsObjects.redBall.body:getPosition()
    localX = math.cos(redBallRot + math.rad(90)) * -20
    localY = math.sin(redBallRot + math.rad(90)) * -20
    realX = redBallX + localX
    realY = redBallY + localY

    --get the points of the terrain
    local terrainPoints = {}
    terrainPoints = {physicsObjects.terrain.shape:getPoints()}
    --get the last x position of the terrain
    local lastX = terrainPoints[#terrainPoints-1]
    local lastY = terrainPoints[#terrainPoints]

    local nearestX = 0
    local nearestY = 0

    --Find the nearest terrain point that the ball is on
    for i = 1, #terrainPoints, 2 do
        if terrainPoints[i] > redBallX then
            local prevX = terrainPoints[i-2]
            local prevY = terrainPoints[i-1] + physicsObjects.terrain.body:getY()
            
            local nextX = terrainPoints[i]
            local nextY = terrainPoints[i+1] + physicsObjects.terrain.body:getY()
            
            nearestX = Lerp(prevX, nextX, (redBallX - prevX)/(nextX - prevX))
            nearestY = Lerp(prevY, nextY, (redBallX - prevX)/(nextX - prevX))
            break
        end
    end

    --ground check position
    local groundCheckX = redBallX - localX/2
    local groundCheckY = redBallY - localY/2

    if groundCheckY <= nearestY then
        isGrounded = false
    else
        isGrounded = true
    end


    --if space is pressed, apply an inital impulse to the physicsObjects.redBall, which will make it jump, if it is held down, it will make it jump higher
    if love.keyboard.isDown("space") then
        if not spaceHeld then
            physicsObjects.redBall.body:applyLinearImpulse(0, -30)
            spaceHeld = true
        else
            local mass = physicsObjects.redBall.body:getMass()
            physicsObjects.redBall.body:applyForce(0, -10000 * dt * mass)
            physicsObjects.redBall.body:applyTorque(-100)
        end
    else 
        physicsObjects.redBall.body:setAngularVelocity(physicsObjects.redBall.body:getAngularVelocity() - (physicsObjects.redBall.body:getAngularVelocity() * dt * 1))
        spaceHeld = false
    end

    --cap the speed of the physicsObjects.redBall to 200
    if physicsObjects.redBall.body:getLinearVelocity() > 800 then
        local x, y = physicsObjects.redBall.body:getLinearVelocity()
        physicsObjects.redBall.body:setLinearVelocity(800, y)
    end

    --cap the rotational speed of the physicsObjects.redBall to 20
    if physicsObjects.redBall.body:getAngularVelocity() < math.rad(-180) then
        physicsObjects.redBall.body:setAngularVelocity(math.rad(-180))
    end

    --if the last x position is less than the redBall x position
    if lastX < physicsObjects.redBall.body:getX() then
        --if old terrain exists, destroy it
        if physicsObjects.oldTerrain ~= nil and physicsObjects.oldTerrain.body ~= nil then
            physicsObjects.oldTerrain.body:destroy()
        end

        physicsObjects.oldTerrain = physicsObjects.terrain

        --create a new terrain
        CreateTerrain(lastX, lastY)
        
    end

    local partX = math.cos(redBallRot) * -25
    local partY = math.sin(redBallRot) * -25
    partX = redBallX + partX
    partY = redBallY + partY

    if isGrounded then
        particleSystem:start()
    else
        particleSystem:pause()
    end

    particleSystem:moveTo(partX, partY)
    particleSystem:update(dt) -- This performs the simulation of the particles.

    --follow the player with the camera
    cam:lookAt(physicsObjects.redBall.body:getX(), physicsObjects.redBall.body:getY())
end

function love.draw()
    --draw the FPS
    love.graphics.setColor(0, 0, 0)
    love.graphics.print("FPS: "..tostring(love.timer.getFPS()), 10, 10)
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("FPS: "..tostring(love.timer.getFPS()), 9, 9)

    cam:attach()

    --draw the ground green
    -- love.graphics.setColor(0, 255, 0)
    -- love.graphics.polygon("fill", physicsObjects.ground.body:getWorldPoints(physicsObjects.ground.shape:getPoints()))

    --draw the platform grey
    love.graphics.setColor(128, 128, 128)
    love.graphics.polygon("fill", physicsObjects.platform.body:getWorldPoints(physicsObjects.platform.shape:getPoints()))

    --draw the redBall red
    love.graphics.setColor(255, 0, 0)
    love.graphics.polygon("line", physicsObjects.redBall.body:getWorldPoints(physicsObjects.redBall.shape:getPoints()))

    --draw a blue circle upwards of the redBall
    love.graphics.setColor(0, 0, 255)
    love.graphics.circle("line", realX, realY, 10)

    --draw the blueBall blue
    love.graphics.setColor(0, 0, 255)
    love.graphics.circle("fill", physicsObjects.blueBall.body:getX(), physicsObjects.blueBall.body:getY(), physicsObjects.blueBall.shape:getRadius())

    --draw the terrain white
    love.graphics.setColor(255, 255, 255)
    love.graphics.line(physicsObjects.terrain.body:getWorldPoints(physicsObjects.terrain.shape:getPoints()))

    --draw the oldTerrain purple (if it exists)
    if physicsObjects.oldTerrain ~= nil then
        love.graphics.setColor(128, 0, 128)
        love.graphics.line(physicsObjects.oldTerrain.body:getWorldPoints(physicsObjects.oldTerrain.shape:getPoints()))
    end

    -- Draw the particle system. Note that we don't need to give the draw()
	-- function any coordinates here as all individual particles have their
	-- own position (which only the particleSystem object knows about).
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(particleSystem)

    cam:detach()
end