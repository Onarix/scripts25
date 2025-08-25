Board = {}
Board.width = 10
Board.height = 20
Board.grid = {}
local lume = require("lume")


function Board:reset()
    self.grid = {}
    for y=1,self.height do
        self.grid[y] = {}
        for x=1,self.width do
            self.grid[y][x] = 0
        end
    end
    gameOver = false
    spawnBlock()
end

currentBlock = {}
currentX = 0
currentY = 0
currentRotation = 1

function spawnBlock()
    local keys = {"I","O","T","L"}
    local choice = keys[math.random(#keys)]
    currentBlock = blocks[choice]
    currentRotation = 1
    currentX = 4
    currentY = 1
end

function checkCollision(xOffset, yOffset, rotation)
    rotation = rotation or currentRotation
    for y,row in ipairs(currentBlock[rotation]) do
        for x,val in ipairs(row) do
            if val ~= 0 then
                local newX = currentX + x + xOffset -1
                local newY = currentY + y + yOffset -1
                if newX < 1 or newX > Board.width or newY > Board.height then
                    return true
                end
                if newY > 0 and Board.grid[newY][newX] ~= 0 then
                    return true
                end
            end
        end
    end
    return false
end

function moveCurrentBlock(dx, dy)
    if not checkCollision(dx, dy) then
        currentX = currentX + dx
        currentY = currentY + dy
    else
        if dy == 1 then 
            fallInterval = fallSpeed
            locked = false
            lockBlock()
            spawnBlock()
            checkGameOver()
        end
    end
end

function rotateBlock()
    local nextRotation = currentRotation + 1
    if nextRotation > #currentBlock then nextRotation = 1 end
    if not checkCollision(0,0,nextRotation) then
        currentRotation = nextRotation
    end
end

function lockBlock()
    for y,row in ipairs(currentBlock[currentRotation]) do
        for x,val in ipairs(row) do
            if val ~= 0 then
                local px = currentX + x -1
                local py = currentY + y -1
                if py > 0 then
                    Board.grid[py][px] = val
                end
            end
        end
    end
    clearLines()
end

function clearLines()
    local y = Board.height
    while y > 0 do
        local full = true
        for x=1,Board.width do
            if Board.grid[y][x] == 0 then
                full = false
                break
            end
        end
        if full then
            table.remove(Board.grid, y)
            local newRow = {}
            for i=1,Board.width do newRow[i]=0 end
            table.insert(Board.grid, 1, newRow)
        else
            y = y - 1
        end
    end
end

function drawBoard()
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", 0, 0, Board.width*30, Board.height*30)
    
    love.graphics.setColor(1,1,1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", 0, 0, Board.width*30, Board.height*30)

    for y=1,Board.height do
        for x=1,Board.width do
            if Board.grid[y][x] ~= 0 then
                love.graphics.setColor(0,1,0)
                love.graphics.rectangle("fill", (x-1)*30, (y-1)*30, 30, 30)
            end
        end
    end
end

function drawCurrentBlock()
    love.graphics.setColor(1,0,0)
    for y,row in ipairs(currentBlock[currentRotation]) do
        for x,val in ipairs(row) do
            if val ~= 0 then
                love.graphics.rectangle("fill", (currentX+x-2)*30, (currentY+y-2)*30, 30, 30)
            end
        end
    end
end

function checkGameOver()
    for x=1,Board.width do
        if Board.grid[1][x] ~= 0 then
            gameOver = true
            break
        end
    end
end

function saveGame()
    local data = {
        grid = Board.grid,
        blockType = currentBlock,
        currentRotation = currentRotation,
        currentX = currentX,
        currentY = currentY
    }
    local serialized = "return " .. lume.serialize(data)
    love.filesystem.write("savegame.lua", serialized)
    gameSaved = true
end

function loadGame()
    if not love.filesystem.getInfo("savegame.lua") then
        gameNoFile = true
        return
    end

    local chunk = love.filesystem.load("savegame.lua")
    local data = chunk() 

    Board.grid             = data.grid
    currentBlock           = data.blockType
    currentRotation        = data.currentRotation
    currentX               = data.currentX
    currentY               = data.currentY

    gameLoaded = true
end
