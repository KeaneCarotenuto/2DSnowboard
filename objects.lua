--create a list of physics objects
physicsObjects = {}

physicsObjects.oldTerrain = nil

function CreateTerrain(_x, _y)
    --initialize empty ground to be used as terrain
    physicsObjects.terrain = {}
    --make terrain body
    physicsObjects.terrain.body = love.physics.newBody(world, 0 , love.graphics.getHeight(), "static");

    --Create a list of points, starting at (0,0), ending at (love.graphics.getWidth(), 0), with a random height between -10 and 10
    local terrainPoints = {}
    for i = 0, love.graphics.getWidth(), 1 do
        table.insert(terrainPoints, _x + (i * 40))
        table.insert(terrainPoints, _y + ((i == 0 and 0 or math.random(-100, 1000)) + i*10) * 2) 
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

    --store first point
    physicsObjects.terrain.firstPointX = terrainPoints[1]
    physicsObjects.terrain.firstPointY = terrainPoints[2]

    --store last point
    physicsObjects.terrain.lastPointX = terrainPoints[#terrainPoints-1]
    physicsObjects.terrain.lastPointY = terrainPoints[#terrainPoints]

    --make terrain shape (chain shape)
    physicsObjects.terrain.shape = love.physics.newChainShape(false, terrainPoints);
    --make terrain fixture
    physicsObjects.terrain.fixture = love.physics.newFixture(physicsObjects.terrain.body, physicsObjects.terrain.shape);



    


    physicsObjects.terrain.rockPoints = {}
    physicsObjects.terrain.snowPoints = {}
    physicsObjects.terrain.consistentSnowPoints = {}
    --Store terrain points temporarily
    local tp = {}
    tp = {physicsObjects.terrain.body:getWorldPoints(physicsObjects.terrain.shape:getPoints())}
    --for each point in the terrainPoints table
    for i = 3, #tp, 2 do
        local depth = 2000
        local snowHieght = 5
        local snowThickness = 100
        local p1x = tp[i-2]
        local p1y = tp[i-1]
        local p2x = tp[i]
        local p2y = tp[i+1]

        local p1ybot = p1y + depth
        local p2ybot = p2y + depth

        --store rock positions
        table.insert(physicsObjects.terrain.rockPoints, p1x)
        table.insert(physicsObjects.terrain.rockPoints, p1y)
        table.insert(physicsObjects.terrain.rockPoints, p2x)
        table.insert(physicsObjects.terrain.rockPoints, p2y)
        table.insert(physicsObjects.terrain.rockPoints, p2ybot)
        table.insert(physicsObjects.terrain.rockPoints, p1ybot)

        --compare against noise function, to randomly add some snow circles on the surface
        local noise = love.math.noise(p1x, p1y)
        local noise2 = love.math.noise(p1x + 10, p1y + 10)
        if noise > 0.5 then
            --store snow positions
            table.insert(physicsObjects.terrain.snowPoints, (p1x + p2x) / 2)
            table.insert(physicsObjects.terrain.snowPoints, (p1y + p2y)/2 + snowHieght)
            table.insert(physicsObjects.terrain.snowPoints, noise2 * 20)
        end

        --draw consistent snow
        love.graphics.setColor(1, 1, 1)
        love.graphics.polygon("fill", {p1x, p1y - snowHieght, p2x, p2y - snowHieght, p2x, p2y + snowThickness, p1x, p1y + snowThickness})

        --store consistent snow positions
        table.insert(physicsObjects.terrain.consistentSnowPoints, p1x)
        table.insert(physicsObjects.terrain.consistentSnowPoints, p1y - snowHieght)
        table.insert(physicsObjects.terrain.consistentSnowPoints, p2x)
        table.insert(physicsObjects.terrain.consistentSnowPoints, p2y - snowHieght)
        table.insert(physicsObjects.terrain.consistentSnowPoints, p2y + snowThickness)
        table.insert(physicsObjects.terrain.consistentSnowPoints, p1y + snowThickness)
    end



    
    --insert draw function
    function physicsObjects.terrain:Draw()
        cam:attach()

        --get the min and max screen coords
        local minX = cam.x - (love.graphics.getWidth() / 2 + 100) / cam.scale
        local maxX = cam.x + (love.graphics.getWidth() / 2 + 100) / cam.scale

        --draw terrain rock
        love.graphics.setColor(0.5, 0.5, 0.5)
        for i = 1, #self.rockPoints, 3*2 do

            local p1x = self.rockPoints[i]
            local p1y = self.rockPoints[i+1]
            local p2x = self.rockPoints[i+2]
            local p2y = self.rockPoints[i+3]
            local p2ybot = self.rockPoints[i+4]
            local p1ybot = self.rockPoints[i+5]

            --check if p1x or p2x is outside of the screen
            if p1x < minX or p2x < minX then
                --do nothing
            elseif p1x > maxX or p2x > maxX then
                break
            else
                --draw terrain rock
                love.graphics.polygon("fill", {p1x, p1y, p2x, p2y, p2x, p2ybot, p1x, p1ybot})
            end
        end

        --draw terrain snow
        love.graphics.setColor(0.9, 0.9, 0.9)
        for i = 1, #self.snowPoints, 3 do
            local x = self.snowPoints[i]
            local y = self.snowPoints[i+1]
            local r = self.snowPoints[i+2]

            --check if p1x or p2x is outside of the screen
            if x < minX then
                --do nothing
            elseif x > maxX then
                break
            else
                --draw terrain snow
                love.graphics.circle("fill", x, y, r)
            end
        end

        local light = true
        --draw terrain consistent snow
        for i = 1, #self.consistentSnowPoints, 3*2 do
            local p1x = self.consistentSnowPoints[i]
            local p1yH = self.consistentSnowPoints[i+1]
            local p2x = self.consistentSnowPoints[i+2]
            local p2yH = self.consistentSnowPoints[i+3]
            local p2yT = self.consistentSnowPoints[i+4]
            local p1yT = self.consistentSnowPoints[i+5]

            --alernate between light and dark snow
            if light then
                love.graphics.setColor(1, 1, 1)
                light = false
            else
                love.graphics.setColor(0.95, 0.95, 0.95)
                light = true
            end

            --check if p1x or p2x is outside of the screen
            if p1x < minX or p2x < minX then
                --do nothing
            elseif p1x > maxX or p2x > maxX then
                break
            else
                --draw terrain consistent snow
                love.graphics.polygon("fill", {p1x, p1yH, p2x, p2yH, p2x, p2yT, p1x, p1yT})
            end
        end

        local lastX, lastY = self:GetFirstPoint()
        lastX = lastX + self.body:getX()
        lastY = lastY + self.body:getY()
        --draw a black line with a white triangle at the top of it, at the start of the terrain
        love.graphics.setColor(0, 0, 0)
        love.graphics.polygon("fill", lastX, lastY, lastX + 5, lastY, lastX + 5, lastY - 100, lastX, lastY - 90)
        love.graphics.setColor(1, 0, 0)
        love.graphics.polygon("fill", lastX, lastY - 100, lastX, lastY - 70, lastX + 40, lastY - 85)

        cam:detach()
    end

    --insert GetLastPoint function
    function physicsObjects.terrain:GetLastPoint()
        return self.lastPointX, self.lastPointY
    end

    --insert Get first point function
    function physicsObjects.terrain:GetFirstPoint()
        return self.firstPointX, self.firstPointY
    end

    --insert GetNearest function
    function physicsObjects.terrain:GetNearest(x, y)
        local tp = {self.body:getWorldPoints(self.shape:getPoints())}
        local nearestX = tp[1]
        local nearestY = tp[2]

        --Find the nearest terrain point that the ball is on
        for i = 3, #tp, 2 do
            if tp[i] > x then
                local prevX = tp[i-2]
                local prevY = tp[i-1]
                
                local nextX = tp[i]
                local nextY = tp[i+1]

                local lerpVal = (x - prevX)/(nextX - prevX)

                --if lerpVal is not between 0 and 1, then do nothing
                if lerpVal < 0 or lerpVal > 1 then

                else 
                    nearestX = Lerp(prevX, nextX, (x - prevX)/(nextX - prevX))
                    nearestY = Lerp(prevY, nextY, (x - prevX)/(nextX - prevX))
                end
                break
            end
        end

        return nearestX, nearestY
    end

end

function GetNearest(x, y)
    --check which terrain the x and y are on
    local newFirstX = physicsObjects.terrain:GetFirstPoint()
    if x > newFirstX then
        return physicsObjects.terrain:GetNearest(x, y)
    else
        if physicsObjects.oldTerrain then
            return physicsObjects.oldTerrain:GetNearest(x, y)
        end
        return x, y
    end
end

function ResetTerrain()
    physicsObjects.terrain.body:destroy()
    if physicsObjects.oldTerrain ~= nil and physicsObjects.oldTerrain ~= {} then physicsObjects.oldTerrain.body:destroy() end
    physicsObjects.terrain = nil
    physicsObjects.oldTerrain = nil

    CreateTerrain(0,0)
end

return physicsObjects