--player class for the game

--player class to store player data and functions for the game
--Store x and y position of the player
--Store the player's health
--Store the player's score

Player = {
    x = 0,
    y = 0,
    health = 100,
    score = 0,
    speed = 0,
    direction = 0,
    image = nil,
    image_width = 0,
    image_height = 0,
    image_x = 0,
    image_y = 0,
    image_scale = 1,
    image_rotation = 0,
    image_alpha = 1,
    image_color = {1,1,1,1},
    image_blend = "alpha",
    image_visible = true,
    image_flip = false,
}