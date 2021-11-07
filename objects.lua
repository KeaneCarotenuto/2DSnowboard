--create a list of physics objects
physicsObjects = {}
physicsObjects.category = {redBall = 1, blueBall = 2, platform = 3, ground = 4}

-- --initialize empty ground
-- physicsObjects.ground = {}
-- --make ground body
-- physicsObjects.ground.body = love.physics.newBody(world, love.graphics.getWidth()/2, love.graphics.getHeight() - 30, "static");
-- --make ground shape
-- physicsObjects.ground.shape = love.physics.newRectangleShape(love.graphics.getWidth(), 50);
-- --make ground fixture
-- physicsObjects.ground.fixture = love.physics.newFixture(physicsObjects.ground.body, physicsObjects.ground.shape);
-- physicsObjects.ground.fixture:setCategory(physicsObjects.category.ground);

--initialize empty red ball
physicsObjects.redBall = {}
--make red ball body
physicsObjects.redBall.body = love.physics.newBody(world, love.graphics.getWidth() / 2 , love.graphics.getHeight() - 200, "dynamic");
--make red ball shape
physicsObjects.redBall.shape = love.physics.newRectangleShape(60, 5);
--make red ball fixture
physicsObjects.redBall.fixture = love.physics.newFixture(physicsObjects.redBall.body, physicsObjects.redBall.shape, 1);
--make ball bouncy
physicsObjects.redBall.fixture:setRestitution(0.0);
--low friction
physicsObjects.redBall.fixture:setFriction(0.0);
physicsObjects.redBall.fixture:setCategory(physicsObjects.category.redBall);
--red ball doesnt collide with platform
physicsObjects.redBall.fixture:setMask(physicsObjects.category.platform);

--initialize empty blue ball
physicsObjects.blueBall = {}
--make blue ball body
physicsObjects.blueBall.body = love.physics.newBody(world, love.graphics.getWidth() / 2 - 50 , love.graphics.getHeight() - 200, "dynamic");
--make blue ball shape
physicsObjects.blueBall.shape = love.physics.newCircleShape(10);
--make blue ball fixture
physicsObjects.blueBall.fixture = love.physics.newFixture(physicsObjects.blueBall.body, physicsObjects.blueBall.shape, 1);
--make ball bouncy
physicsObjects.blueBall.fixture:setRestitution(0.6);
physicsObjects.blueBall.fixture:setCategory(physicsObjects.category.blueBall);

--initialize empty platform
physicsObjects.platform = {}
--make platform body
physicsObjects.platform.body = love.physics.newBody(world, love.graphics.getWidth() / 2 , love.graphics.getHeight() - 100, "static");
--make platform shape
physicsObjects.platform.shape = love.physics.newRectangleShape(300, 50);
--make platform fixture
physicsObjects.platform.fixture = love.physics.newFixture(physicsObjects.platform.body, physicsObjects.platform.shape, 5);
physicsObjects.platform.fixture:setCategory(physicsObjects.category.platform);

physicsObjects.oldTerrain = nil

function CreateTerrain(_x, _y)
    --initialize empty ground to be used as terrain
    physicsObjects.terrain = {}
    --make terrain body
    physicsObjects.terrain.body = love.physics.newBody(world, 0 , love.graphics.getHeight(), "static");

    --Create a list of points, starting at (0,0), ending at (love.graphics.getWidth(), 0), with a random height between -10 and 10
    local terrainPoints = {}
    for i = 0, love.graphics.getWidth(), 1 do
        table.insert(terrainPoints, _x + (i * 20))
        table.insert(terrainPoints, _y + (i == 0 and 0 or math.random(-100, 100)) + i*5)
    end

    --loop through the list of points and average the height based on the points around it
    for i = 0, 50, 1 do
        for i = 2, #terrainPoints, 2 do
            
            if i > 2 and i <= #terrainPoints - 2 then
                local average = 0
                average = (terrainPoints[i-2] + terrainPoints[i] + terrainPoints[i+2]) / 3
                terrainPoints[i] = average
            end
            
        end
    end

    --check that the amount of points is even, if not duplicate the last point
    if #terrainPoints % 2 ~= 0 then
        table.insert(terrainPoints, terrainPoints[#terrainPoints])
        table.insert(terrainPoints, terrainPoints[#terrainPoints - 1])
    end

    for r = 0, 2, 1 do
        --get the index of a random point
        local randomIndex = math.random(1, #terrainPoints / 2)
        local increment = 0
        local incInc = 0.1
        --slope the points after the random index slightly to make a ramp
        for i = randomIndex * 2, randomIndex * 2 + (20 * 2), 2 do
            --if the point is outside of the terrainPoints list, then continue
            if i > #terrainPoints then
                
            else
                terrainPoints[i] = terrainPoints[i - 2] - increment
                increment = increment + incInc
                incInc = incInc + 0.01
            end
        end
    end

    --make terrain shape (chain shape)
    physicsObjects.terrain.shape = love.physics.newChainShape(false, terrainPoints);
    --make terrain fixture
    physicsObjects.terrain.fixture = love.physics.newFixture(physicsObjects.terrain.body, physicsObjects.terrain.shape);
    physicsObjects.terrain.fixture:setCategory(physicsObjects.category.ground);
end

CreateTerrain(0,0)

return physicsObjects