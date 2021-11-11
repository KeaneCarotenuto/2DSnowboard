Heli = {
    anim = nil,
    angle = 0
}

function Heli:CreateHeliAnim(x,y)
    local animation = {}
    animation.x = x
    animation.y = y
    animation.walkSheet = love.graphics.newImage('assets/heli_anim.png')
    animation.imageDimension = {animation.walkSheet:getDimensions()}
    animation.width = 1800/6
    animation.height = 144
    animation.walkGrid = anim8.newGrid(animation.width, animation.height, animation.imageDimension[1], animation.imageDimension[2])
    animation.walkGridAnimation = anim8.newAnimation(animation.walkGrid('1-6', 1), 0.05)
  
    Heli.anim = animation
end

function Heli:Reset(x,y)
    Heli.angle = 0
    Heli.anim.x = x
    Heli.anim.y = y
end

return Heli