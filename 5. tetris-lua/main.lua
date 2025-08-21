love.graphics.setDefaultFilter("nearest", "nearest")

require "blocks"
require "game"

function love.load()
    Board:reset()
    spawnBlock()
    fallTimer = 0
    fallSpeed = 0.5     
    fastFallSpeed = 0.01 
    fallInterval = fallSpeed
    locked = false
end

function love.update(dt)
    fallTimer = fallTimer + dt
    if fallTimer >= fallInterval then
        fallTimer = 0
        moveCurrentBlock(0, 1)
    end
end

function love.draw()
    if gameOver then
        love.graphics.setColor(1,0,0)
        love.graphics.printf("GAME OVER\nPress R to restart", 0, 200, Board.width*30, "center")
        return
    end

    drawBoard()
    drawCurrentBlock()
end

function love.keypressed(key)
    if gameOver and key == "r" then
        Board:reset()
        return
    end

    if locked == false then
        if key == "left" then moveCurrentBlock(-1, 0)
        elseif key == "right" then moveCurrentBlock(1, 0)
        elseif key == "down" then 
            fallInterval = fastFallSpeed 
            locked = true
        elseif key == "up" then rotateBlock()
        end
    end
end

