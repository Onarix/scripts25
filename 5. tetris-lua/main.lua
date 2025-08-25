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
    gameSaved = false
    gameLoaded = false
    gameNoFile = false
    sounds = {
        rotate   = love.audio.newSource("sounds/rotate.wav", "static"),
        drop     = love.audio.newSource("sounds/drop.wav", "static"),
        line     = love.audio.newSource("sounds/lineclear.wav", "static"),
        save     = love.audio.newSource("sounds/save.wav", "static"),
        load     = love.audio.newSource("sounds/load.wav", "static"),
    }
end

function love.update(dt)
    if gameOver or gameSaved then
        return
    end

    updateLineClear(dt)

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

    if gameSaved then
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Game saved!\nPress any key to continue...",
            0, love.graphics.getHeight()/2 - 30, love.graphics.getWidth(), "center")
        return
    end
    
    if gameLoaded then
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Game loaded!\nPress any key to continue...",
            0, love.graphics.getHeight()/2 - 30, love.graphics.getWidth(), "center")
        return
    end

    if gameNoFile then
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 0 , 0)
        love.graphics.printf("Save file does not exist!\nPress any key to continue...",
            0, love.graphics.getHeight()/2 - 30, love.graphics.getWidth(), "center")
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

    if gameSaved then
        gameSaved = false
        return
    end

    if gameLoaded then
        gameLoaded = false
        return
    end

    if gameNoFile then
        gameNoFile = false
        return
    end

    if key == "s" then
        saveGame()
    elseif key == "l" then
        loadGame()
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

