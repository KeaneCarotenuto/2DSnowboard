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

local maxVel = 800

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
	particleSystem:setSpread(math.rad(90))
    particleSystem:setDirection(math.rad(-45))
	particleSystem:setSpeed(100, 100)
	particleSystem:setColors(1,1,1,1)
end

function love.keypressed(key, scancode, isrepeat)

end

function love.update(dt)
    --update the physics world
    world:update(dt)

    redBallRot = physicsObjects.redBall.body:getAngle()
    --convert the angle to degrees
    local degrees = math.deg(redBallRot)
    degrees = math.fmod(degrees, 360)
    --clamp the degrees between -180 and 180
    if degrees > 180 then
        degrees = degrees - 360
    elseif degrees < -180 then
        degrees = degrees + 360
    end
    redBallRot = math.rad(degrees)

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

    local prevX = 0
    local prevY = 0
    
    local nextX = 0
    local nextY = 0

    local nearestX = 0
    local nearestY = 0


    --Find the nearest terrain point that the ball is on
    for i = 1, #terrainPoints, 2 do
        if terrainPoints[i] > redBallX then
            prevX = terrainPoints[i-2]
            prevY = terrainPoints[i-1] + physicsObjects.terrain.body:getY()
            
            nextX = terrainPoints[i]
            nextY = terrainPoints[i+1] + physicsObjects.terrain.body:getY()
            
            nearestX = Lerp(prevX, nextX, (redBallX - prevX)/(nextX - prevX))
            nearestY = Lerp(prevY, nextY, (redBallX - prevX)/(nextX - prevX))
            break
        end
    end

    --calculate the normal of the terrain at the nearest point
    local normalX = -(nextY - prevY)
    local normalY = (nextX - prevX)
    local normalLength = math.sqrt(normalX^2 + normalY^2)
    normalX = normalX/normalLength
    normalY = normalY/normalLength

    --ground check position
    groundCheckX = redBallX - localX/2
    groundCheckY = redBallY - localY/2

    if groundCheckY <= nearestY then
        isGrounded = false
    else
        isGrounded = true
    end

    local moving = false
    --If the A and D keys are pressed, apply torque to the ball to rotate it
    if love.keyboard.isDown("a") then
        physicsObjects.redBall.body:applyTorque(-100)
        moving = true
    end
    if love.keyboard.isDown("d") then
        physicsObjects.redBall.body:applyTorque(100)
        moving = true
    end

    --if space is pressed, apply an inital impulse to the physicsObjects.redBall, which will make it jump, if it is held down, it will make it jump higher
    if love.keyboard.isDown("space") then
        if isGrounded and not spaceHeld then
            physicsObjects.redBall.body:applyLinearImpulse(0, -30)
        else
            local mass = physicsObjects.redBall.body:getMass()
            physicsObjects.redBall.body:applyForce(0, -100 * mass)
        end
        
        moving = true
        spaceHeld = true
    else 
        
        --apply torque to rotate the redBall towards up
        -- local angleDiff = (0 - redBallRot)
        -- local force = angleDiff * 10
        -- physicsObjects.redBall.body:applyTorque(force)
        spaceHeld = false
    end

    if not moving then
        physicsObjects.redBall.body:setAngularVelocity(physicsObjects.redBall.body:getAngularVelocity() - (physicsObjects.redBall.body:getAngularVelocity() * dt * 2))
    end

    --apply linear drag to the redBall
    physicsObjects.redBall.body:applyForce(-physicsObjects.redBall.body:getLinearVelocity() * 0.01, 0)


    --cap the speed of the physicsObjects.redBall to 200
    if physicsObjects.redBall.body:getLinearVelocity() > maxVel then
        local x, y = physicsObjects.redBall.body:getLinearVelocity()
        physicsObjects.redBall.body:setLinearVelocity(maxVel, y)
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

    local partX = math.cos(redBallRot) * 25
    local partY = math.sin(redBallRot) * 25
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
    --calculate how fast the redBall is moving compared to the maxVel
    local speed = physicsObjects.redBall.body:getLinearVelocity()
    local speedPercent = speed/maxVel
    --set the camera zoom based on the speed of the redBall
    local newZoom = 1.25 - (speedPercent)/2
    cam:zoomTo(Lerp(cam.scale, newZoom, dt))
    
end

function love.draw()
    cam:attach()

    --draw the ground green
    -- love.graphics.setColor(0, 255, 0)
    -- love.graphics.polygon("fill", physicsObjects.ground.body:getWorldPoints(physicsObjects.ground.shape:getPoints()))

    --draw the platform grey
    love.graphics.setColor(128, 128, 128)
    love.graphics.polygon("fill", physicsObjects.platform.body:getWorldPoints(physicsObjects.platform.shape:getPoints()))

    --draw a line from the redBall to the groundCheck point
    -- love.graphics.setColor(255, 0, 0)
    -- love.graphics.line(redBallX, redBallY, groundCheckX, groundCheckY)

    --draw the blueBall blue
    love.graphics.setColor(0, 0, 255)
    love.graphics.circle("fill", physicsObjects.blueBall.body:getX(), physicsObjects.blueBall.body:getY(), physicsObjects.blueBall.shape:getRadius())

    --Store terrain points temporarily
    local terrainPoints = {}
    terrainPoints = {physicsObjects.terrain.body:getWorldPoints(physicsObjects.terrain.shape:getPoints())}
    --for each point in the terrainPoints table
    for i = 3, #terrainPoints, 2 do
        local depth = 2000
        local snowHieght = 5
        local snowThickness = 100
        local p1x = terrainPoints[i-2]
        local p1y = terrainPoints[i-1]
        local p2x = terrainPoints[i]
        local p2y = terrainPoints[i+1]

        local p1ybot = p1y + depth
        local p2ybot = p2y + depth

        --Draw rock
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.polygon("fill", {p1x, p1y, p2x, p2y, p2x, p2ybot, p1x, p1ybot})

        --compare against noise function, to randomly add some snow circles on the surface
        local noise = love.math.noise(p1x, p1y)
        local noise2 = love.math.noise(p1x + 10, p1y + 10)
        if noise > 0.5 then
            love.graphics.setColor(0.9, 0.9, 0.9)
            love.graphics.circle("fill", (p1x + p2x) / 2, (p1y + p2y)/2 + snowHieght, noise2 * 20)
        end

        --draw consistent snow
        love.graphics.setColor(1, 1, 1)
        love.graphics.polygon("fill", {p1x, p1y - snowHieght, p2x, p2y - snowHieght, p2x, p2y + snowThickness, p1x, p1y + snowThickness})
    end

    --draw the oldTerrain purple (if it exists)
    if physicsObjects.oldTerrain ~= nil then
        love.graphics.setColor(128, 0, 128)
        love.graphics.line(physicsObjects.oldTerrain.body:getWorldPoints(physicsObjects.oldTerrain.shape:getPoints()))
    end

    --draw the redBall red
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("fill", physicsObjects.redBall.body:getWorldPoints(physicsObjects.redBall.shape:getPoints()))

    --draw a blue circle upwards of the redBall
    love.graphics.setColor(0, 0, 1)
    love.graphics.circle("fill", realX, realY, 10)

    -- Draw the particle system. Note that we don't need to give the draw()
	-- function any coordinates here as all individual particles have their
	-- own position (which only the particleSystem object knows about).
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(particleSystem)

    cam:detach()

    --draw the FPS
    love.graphics.setColor(0, 0, 0)
    love.graphics.print("FPS: "..tostring(love.timer.getFPS()), 10, 10)
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("FPS: "..tostring(love.timer.getFPS()), 9, 9)
end