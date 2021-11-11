--player class for the game

--player class to store player data and functions for the game
--Store x and y position of the player
--Store the player's health
--Store the player's score

Player = {
    board = nil,
    bodyParts = {},
    anim = nil,
    particles = nil,
    lastFlipAngle = 0,
    flips = 0,
    maxVel = 800,
    x = 0,
    y = 0,
    totalRotation = 0,
    currentAngle = 0,
    upX = 0,
    upY = 1,
    rightX = 1,
    rightY = 0,
    isGrounded = false,
    spaceHeld = false,
    alive = true,

    -- x = 0,
    -- y = 0,
    -- health = 100,
    -- score = 0,
    -- speed = 0,
    -- direction = 0,
    -- image = nil,
    -- image_width = 0,
    -- image_height = 0,
    -- image_x = 0,
    -- image_y = 0,
    -- image_scale = 1,
    -- image_rotation = 0,
    -- image_alpha = 1,
    -- image_color = {1,1,1,1},
    -- image_blend = "alpha",
    -- image_visible = true,
    -- image_flip = false,
}

function Player:Update(dt)
    self:GetPos()
    self:GetTotalRotation()
    self:GetCurrentAngle()
    self:GetUpVector()
    self:GetRightVector()

    if self.alive then
        if (math.deg(math.abs(self.board.body:getAngle() - self.lastFlipAngle)) > 360) then
            Player:AddFlip()
        end
    
        local nearestX , nearestY = GetNearest(self.x, self.y)
        local upX, upY = Player:GetUpVector(1)
    
        --ground check position
        local groundCheckX = self.x - upX * 20
        local groundCheckY = self.y - upY * 20
        local personCheckX = self.x + upX * 75
        local personCheckY = self.y + upY * 75
    
        if groundCheckY <= nearestY then
            self.isGrounded = false
            self.anim.walkGridAnimation:gotoFrame(1)
        else
            if self.isGrounded == false then
                if (math.deg(math.abs(self.board.body:getAngle() - self.lastFlipAngle)) > 180) then
                    Player:AddFlip()
                end
            end
            self.isGrounded = true
            self.anim.walkGridAnimation:gotoFrame(4)
        end
    
        if personCheckY >= nearestY then
            self:Die()
        else
    
        end
    
        local moving = false
        --If the A and D keys are pressed, apply torque to the ball to rotate it
        if love.keyboard.isDown("a") then
            self.board.body:applyTorque(-100)
            moving = true
        end
        if love.keyboard.isDown("d") then
            self.board.body:applyTorque(100)
            moving = true
        end
    
        --if space is pressed, apply an inital impulse to the physicsObjects.redBall, which will make it jump, if it is held down, it will make it jump higher
        if love.keyboard.isDown("space") then
            if self.isGrounded and not self.spaceHeld then
                self.board.body:applyLinearImpulse(0, -30)
            else
                local mass = self.board.body:getMass()
                self.board.body:applyForce(0, -100 * mass)
            end
            
            moving = true
            self.spaceHeld = true
        else 
            self.spaceHeld = false
        end
    
        if not moving then
            self.board.body:setAngularVelocity(self.board.body:getAngularVelocity() - (self.board.body:getAngularVelocity() * dt * 2))
        end
    
        --apply linear drag to the redBall
        self.board.body:applyForce(-self.board.body:getLinearVelocity() * 0.01, 0)
    
    
        --cap the speed of the physicsObjects.redBall to 200
        if self.board.body:getLinearVelocity() > self.maxVel then
            local x, y = self.board.body:getLinearVelocity()
            self.board.body:setLinearVelocity(self.maxVel, y)
        end
    
        --cap the rotational speed of the physicsObjects.redBall to 20
        if self.board.body:getAngularVelocity() < math.rad(-150) then
            self.board.body:setAngularVelocity(math.rad(-150))
        elseif self.board.body:getAngularVelocity() > math.rad(150) then
            self.board.body:setAngularVelocity(math.rad(150))
        end
    
        if self.isGrounded then
            self.particles:start()
        else
            self.particles:pause()
        end
    else
        self.particles:pause()

        --apply linear drag to the redBall
        --self.board.body:applyForce(-self.board.body:getLinearVelocity() * 0.1, 0)

        --set the friction of the body to 1
        self.board.fixture:setFriction(0.8);
    end
    

    self.particles:moveTo(self.x + self.rightX * 25, self.y + self.rightY * 25)
    self.particles:update(dt) -- This performs the simulation of the particles.

    self.anim.walkGridAnimation:update(dt)
    self.particles:update(dt)
end

function Player:Draw()
    cam:attach()

    love.graphics.setColor(0, 0, 0)
    love.graphics.polygon("fill", self.board.body:getWorldPoints(self.board.shape:getPoints()))

    -- Draw the particle system. Note that we don't need to give the draw()
	-- function any coordinates here as all individual particles have their
	-- own position (which only the particleSystem object knows about).
	love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.particles)

    --if player is dead, draw the body parts
    if not self.alive then
        --draw circel head
        love.graphics.setColor(1, 0, 0)
        love.graphics.circle("fill", self.bodyParts.head.body:getX(), self.bodyParts.head.body:getY(), self.bodyParts.head.shape:getRadius())

        --draw rectangle body
        love.graphics.setColor(1, 0, 0)
        love.graphics.polygon("fill", self.bodyParts.body.body:getWorldPoints(self.bodyParts.body.shape:getPoints()))

        --draw rectangle left arm
        love.graphics.setColor(1, 0, 0)
        love.graphics.polygon("fill", self.bodyParts.leftArm.body:getWorldPoints(self.bodyParts.leftArm.shape:getPoints()))

        --draw rectangle right arm
        love.graphics.setColor(1, 0, 0)
        love.graphics.polygon("fill", self.bodyParts.rightArm.body:getWorldPoints(self.bodyParts.rightArm.shape:getPoints()))

        --draw rectangle left leg
        love.graphics.setColor(1, 0, 0)
        love.graphics.polygon("fill", self.bodyParts.leftLeg.body:getWorldPoints(self.bodyParts.leftLeg.shape:getPoints()))

        --draw rectangle right leg
        love.graphics.setColor(1, 0, 0)
        love.graphics.polygon("fill", self.bodyParts.rightLeg.body:getWorldPoints(self.bodyParts.rightLeg.shape:getPoints()))

    else
        love.graphics.setColor(1, 1, 1)
        self.anim.walkGridAnimation:draw(self.anim.walkSheet, self.x + self.upX * 30, self.y + self.upY * 30, self.totalRotation, 0.2, 0.2, self.anim.width/2, self.anim.height/2)
    end

    cam:detach()
end

function Player:Die()
    self.alive = false

    --empty the list
    self.bodyParts = {}

    --Create body parts 
    --make head
    self.bodyParts.head = {}
    --make head body
    self.bodyParts.head.body = love.physics.newBody(world, self.x , self.y - 50, "dynamic");
    --make head shape
    self.bodyParts.head.shape = love.physics.newCircleShape(10);
    --make head fixture
    self.bodyParts.head.fixture = love.physics.newFixture(self.bodyParts.head.body, self.bodyParts.head.shape, 1);
    --set friction
    self.bodyParts.head.fixture:setFriction(0.8);

    --make body
    self.bodyParts.body = {}
    --make body body
    self.bodyParts.body.body = love.physics.newBody(world, self.x , self.y - 30, "dynamic");
    --make body shape
    self.bodyParts.body.shape = love.physics.newRectangleShape(20, 40);
    --make body fixture
    self.bodyParts.body.fixture = love.physics.newFixture(self.bodyParts.body.body, self.bodyParts.body.shape, 1);
    --set friction
    self.bodyParts.body.fixture:setFriction(0.8);

    --make left arm
    self.bodyParts.leftArm = {}
    --make left arm body
    self.bodyParts.leftArm.body = love.physics.newBody(world, self.x - 20 , self.y - 30, "dynamic");
    --make left arm shape
    self.bodyParts.leftArm.shape = love.physics.newRectangleShape(40, 10);
    --make left arm fixture
    self.bodyParts.leftArm.fixture = love.physics.newFixture(self.bodyParts.leftArm.body, self.bodyParts.leftArm.shape, 1);
    --set friction
    self.bodyParts.leftArm.fixture:setFriction(0.8);

    --make right arm
    self.bodyParts.rightArm = {}
    --make right arm body
    self.bodyParts.rightArm.body = love.physics.newBody(world, self.x + 20 , self.y - 30, "dynamic");
    --make right arm shape
    self.bodyParts.rightArm.shape = love.physics.newRectangleShape(40, 10);
    --make right arm fixture
    self.bodyParts.rightArm.fixture = love.physics.newFixture(self.bodyParts.rightArm.body, self.bodyParts.rightArm.shape, 1);
    --set friction
    self.bodyParts.rightArm.fixture:setFriction(0.8);

    --make left leg
    self.bodyParts.leftLeg = {}
    --make left leg body
    self.bodyParts.leftLeg.body = love.physics.newBody(world, self.x - 10, self.y, "dynamic");
    --make left leg shape
    self.bodyParts.leftLeg.shape = love.physics.newRectangleShape(15, 50);
    --make left leg fixture
    self.bodyParts.leftLeg.fixture = love.physics.newFixture(self.bodyParts.leftLeg.body, self.bodyParts.leftLeg.shape, 1);
    --set friction
    self.bodyParts.leftLeg.fixture:setFriction(0.8);

    --make right leg
    self.bodyParts.rightLeg = {}
    --make right leg body
    self.bodyParts.rightLeg.body = love.physics.newBody(world, self.x + 15 , self.y, "dynamic");
    --make right leg shape
    self.bodyParts.rightLeg.shape = love.physics.newRectangleShape(15, 50);
    --make right leg fixture
    self.bodyParts.rightLeg.fixture = love.physics.newFixture(self.bodyParts.rightLeg.body, self.bodyParts.rightLeg.shape, 1);
    --set friction
    self.bodyParts.rightLeg.fixture:setFriction(0.8);



end

--Get player body position
function Player:GetPos()
    self.x, self.y = self.board.body:getPosition()
    return self.x, self.y
end

--Set player body position
function Player:SetPos(x, y)
    self.x = x
    self.y = y
    self.board.body:setPosition(x, y)
end

--get rotation
function Player:GetTotalRotation()
    self.totalRotation = self.board.body:getAngle()
    return self.totalRotation
end

--get angle
function Player:GetCurrentAngle()
    local realAngle = self.board.body:getAngle()
    --convert the angle to degrees
    local degrees = math.deg(realAngle)
    degrees = math.fmod(degrees, 360)
    --clamp the degrees between -180 and 180
    if degrees > 180 then
        degrees = degrees - 360
    elseif degrees < -180 then
        degrees = degrees + 360
    end
    realAngle = math.rad(degrees)
    self.currentAngle = realAngle
    return self.currentAngle
end

--get up vector
function Player:GetUpVector(scale)
    scale = scale or 1
    local angle = self:GetCurrentAngle()
    local upX = math.cos(angle - math.rad(90)) 
    local upY = math.sin(angle - math.rad(90)) 
    self.upX = upX
    self.upY = upY
    return self.upX * scale, self.upY * scale
end

--get right vector
function Player:GetRightVector(scale)
    scale = scale or 1
    local angle = self:GetCurrentAngle()
    local rightX = math.cos(angle) 
    local rightY = math.sin(angle) 
    self.rightX = rightX
    self.rightY = rightY
    return self.rightX * scale, self.rightY * scale
end

function Player:AddFlip()
    self.flips = self.flips + 1
    self.lastFlipAngle = self.board.body:getAngle()
end

function Player:CreateBoard()
    --initialize empty red ball
    physicsObjects.board = {}
    --make red ball body
    physicsObjects.board.body = love.physics.newBody(world, love.graphics.getWidth() / 2 , love.graphics.getHeight() - 200, "dynamic");
    --make red ball shape
    physicsObjects.board.shape = love.physics.newRectangleShape(60, 5);
    --make red ball fixture
    physicsObjects.board.fixture = love.physics.newFixture(physicsObjects.board.body, physicsObjects.board.shape, 1);
    --make ball bouncy
    physicsObjects.board.fixture:setRestitution(0.0);
    --low friction
    physicsObjects.board.fixture:setFriction(0.0);

    self.board = physicsObjects.board;
end

function Player:CreateParticles()
    -- Create a simple image with a single white pixel to use for the particles.
	-- We could load an image from the hard drive but this is just an example.
	local imageData = love.image.newImageData(1, 1)
	imageData:setPixel(0,0, 1,1,1,1)

	local image = love.graphics.newImage(imageData)

    -- Create and initialize the particle system object.
	self.particles = love.graphics.newParticleSystem(image, 1000)
	self.particles:setEmissionRate(150)
	self.particles:setParticleLifetime(0.1, 0.5)
	self.particles:setSizes(2)
	self.particles:setSpread(math.rad(90))
    self.particles:setDirection(math.rad(-45))
	self.particles:setSpeed(100, 100)
	self.particles:setColors(1,1,1,1)
end

function Player:CreatePlayerAnim(x,y)
    local animation = {}
    animation.x = x
    animation.y = y
    animation.walkSheet = love.graphics.newImage('assets/walk2.png')
    animation.imageDimension = {animation.walkSheet:getDimensions()}
    animation.width = 1472/8
    animation.height = 325
    animation.walkGrid = anim8.newGrid(animation.width, animation.height, animation.imageDimension[1], animation.imageDimension[2])
    animation.walkGridAnimation = anim8.newAnimation(animation.walkGrid('1-8', 1), 0.10)
  
    self.anim = animation
  end

  function Player:Reset()
    self.alive = true
    --destroy old body parts
    for k, v in pairs(self.bodyParts) do
        v.body:destroy()
    end
    self:SetPos(love.graphics.getWidth() / 2, love.graphics.getHeight() - 200)
    self.board.body:setLinearVelocity(0, 0)
    self.board.body:setAngularVelocity(0)
    self.board.body:setAngle(0)
  end

return Player