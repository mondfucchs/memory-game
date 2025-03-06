local love = require("love")
local c    = require("libs.clock")
local u    = require("libs.utils")

math.randomseed(os.clock() * 1993, os.clock() * 3991)

-- Helper functions:
local function createBoard(x_, y_)
    local cards        = {}
    for i = 1, (x_*y_)/2 do
        table.insert(cards, i)
        table.insert(cards, i)
    end

    local board        = {}
    for x = 1, x_, 1 do
        board[x]    = {}
        for y = 1, y_ do
            --[[
                This method probably isn't the most adequate one. However, it will probably suffice for now.
                It takes one random card (that is, takes one random index), put that card
                into the board position, and then takes out the card of the cards table.
            ]]
            local cardPos = math.random(1, #cards)
            board[x][y]   = {content=cards[cardPos], clicked=false, active=true}
            table.remove(cards, cardPos)
        end
    end

    return board
end

function love.load()
    -- Clock:
    mainclock = {}

    game = {}
    game.state = "playing"

    -- Errors:
    errors = {
        invalidBoardSize = false
    }

    -- Creating the 'board':
    boardX    = 4
    boardY    = 4
    board = createBoard(boardX, boardY)
    boardPos = {x=80, y=128}

    cardsPicked = {}


    -- Loading assets:
    lilFont = love.graphics.newFont("assets/fonts/04B_03_.TTF", 16)
    midFont = love.graphics.newFont("assets/fonts/04B_03_.TTF", 32)
    background = love.graphics.newImage("assets/img/background.png")
    cursor = love.graphics.newImage("assets/img/cursor.png")
    heartworks = love.graphics.newImage("assets/img/heartworks.png")
    configButton = love.graphics.newImage("assets/img/conf.png")
    errInvalidBoardSize = love.graphics.newImage("assets/img/err_invalidBoardSize.png")

    -- Setting graphics:
    love.graphics.setFont(lilFont)
    love.graphics.setColor(0, 0, 0)
    love.graphics.setBackgroundColor(1, 1, 1)
    love.mouse.setVisible(false)

    -- GUI:

    -- Config:
    configurations = {
        borderThiccness = 8
    }
end

function love.update(dt)
    if     game.state == "playing" then
        if (boardX * boardY) % 2 ~= 0 or boardX * boardY < 0 then
            errors.invalidBoardSize = true
        else
            errors.invalidBoardSize = false
        end

        c.runClock(mainclock, dt)

        if #cardsPicked == 2 then
            if cardsPicked[1].content == cardsPicked[2].content then
                local x1, y1 = cardsPicked[1].x, cardsPicked[1].y
                local x2, y2 = cardsPicked[2].x, cardsPicked[2].y
                c.addTimer(mainclock, 0.25, function()
                    board[x1][y1].active = false
                    board[x2][y2].active = false
                end, "atEnd", "waitingForResults")
            else
                local x1, y1 = cardsPicked[1].x, cardsPicked[1].y
                local x2, y2 = cardsPicked[2].x, cardsPicked[2].y
                c.addTimer(mainclock, 0.25, function()
                    board[x1][y1].clicked = false
                    board[x2][y2].clicked = false
                end, "atEnd", "waitingForResults")
            end
            cardsPicked = {}
        end
    elseif game.state == "menu" then
    end
end

function love.draw()
    if game.state == "playing" then
        love.graphics.draw(background, 0, 0)

        love.graphics.setColor(50/256, 50/256, 50/256)
        love.graphics.rectangle("fill", boardPos.x-configurations.borderThiccness, boardPos.y-configurations.borderThiccness, 80*boardX+configurations.borderThiccness*2, 80*boardY+configurations.borderThiccness*2)
        love.graphics.setColor(1, 1, 1)

        for x, row in pairs(board) do
            for y, card in pairs(row) do
                if card.active and card.clicked then
                    love.graphics.print(card.content, boardPos.x + (x - 1)*80+25, boardPos.y + (y - 1)*80+14)
                elseif card.active and not card.clicked then
                    local color = u.boolToInteger(((y - 1)+(x - 1))%2 == 0, {155/255, 173/255, 183/255}, {1, 1, 1})

                    love.graphics.setColor(u.unpackLove(color))
                    love.graphics.rectangle("fill", boardPos.x + (x - 1)*80, boardPos.y + (y - 1)*80, 80, 80)
                    love.graphics.setColor(1, 1, 1)
                end
            end
        end
        love.graphics.draw(configButton, love.graphics.getWidth() - 48, 16)
    end

    if errors.invalidBoardSize then
        love.graphics.draw(errInvalidBoardSize, 0, 0)
        love.graphics.setColor(231/255, 74/255, 153/255)
        love.graphics.print("Invalid Board Size - game may crash", 24, 1)
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(heartworks, 16, love.graphics.getHeight() - 30)
    love.graphics.draw(cursor, u.roundTo(love.mouse.getX(), 8), u.roundTo(love.mouse.getY(), 8))
end

function love.keypressed(key)
    if key == "up" or key == "w" then
        boardY = boardY - 1
        board = createBoard(boardX, boardY)
    elseif key == "down" or key == "s" then
        boardY = boardY + 1
        board = createBoard(boardX, boardY)
    elseif key == "right" or key == "d" then
        boardX = boardX + 1
        board = createBoard(boardX, boardY)
    elseif key == "left" or key == "a" then
        boardX = boardX - 1
        board = createBoard(boardX, boardY)
    end
end

function love.mousepressed(x, y)
    if game.state == "playing" then
        -- Checking if mouse clicked in any of the cards
        if not mainclock.waitingForResults then
            for _x, row in pairs(board) do
                for _y, card in pairs(row) do
                    if (card.clicked == false) and (card.active  == true) and (x >= boardPos.x + (_x-1)*80 and x < boardPos.x + (_x-1)*80+80) and (y >= boardPos.y + (_y-1)*80 and y < boardPos.y + (_y-1)*80+80) then
                        table.insert(cardsPicked, {content=card.content, x=_x, y=_y})
                        card.clicked = true
                    end
                end
            end
        end
    end
end