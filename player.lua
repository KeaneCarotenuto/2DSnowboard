--player class for the game

--player class to store player data and functions for the game
--Store x and y position of the player
--Store the player's health
--Store the player's score

Player = {
    board = nil,
    anim = nil,
    lastFlipAngle = 0,
    flips = 0,
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

--Get player body position
function Player:GetPos()
    return self.board.body:getPosition()
end

--Set player body position
function Player:SetPos(x, y)
    self.board.body:setPosition(x, y)
end

function Player:AddFlip()
    self.flips = self.flips + 1
    self.lastFlipAngle = self.board.body:getAngle()
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
  
    Player.anim = animation
  end

return Player