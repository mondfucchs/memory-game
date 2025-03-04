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

    -- Creating the 'board':
    boardX    = 4
    boardY    = 4
    board = createBoard(boardX, boardY)

    cardsPicked = {}
    score = 0

    -- Loading assets:
    midFont = love.graphics.newFont("assets/fonts/04B_03_.TTF", 64)

    -- Setting graphics:
    love.graphics.setFont(midFont)
    love.graphics.setColor(0, 0, 0)
    love.graphics.setBackgroundColor(1, 1, 1)

    -- Config:
    configurations = {
        borderThiccness = 8
    }
end

function love.update(dt)
    c.runClock(mainclock, dt)

    if #cardsPicked == 2 then
        if cardsPicked[1].content == cardsPicked[2].content then
            score = score + 5
            local x1, y1 = cardsPicked[1].x, cardsPicked[1].y
            local x2, y2 = cardsPicked[2].x, cardsPicked[2].y
            c.addTimer(mainclock, 0.25, function()
                board[x1][y1].active = false
                board[x2][y2].active = false
            end, "atEnd", "waitingForResults")
        else
            score = score - 1
            local x1, y1 = cardsPicked[1].x, cardsPicked[1].y
            local x2, y2 = cardsPicked[2].x, cardsPicked[2].y
            c.addTimer(mainclock, 0.25, function()
                board[x1][y1].clicked = false
                board[x2][y2].clicked = false
            end, "atEnd", "waitingForResults")
        end
        cardsPicked = {}
    end
end

function love.draw()
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 80-configurations.borderThiccness, 80-configurations.borderThiccness, 80*boardX+configurations.borderThiccness*2, 80*boardY+configurations.borderThiccness*2)
    love.graphics.setColor(1, 1, 1)

    for x, row in pairs(board) do
        for y, card in pairs(row) do
            if card.active and card.clicked then
                love.graphics.print(card.content, x*80+25, y*80+14)
            elseif card.active and not card.clicked then
                local color = u.boolToInteger((y+x)%2 == 0, {155/255, 173/255, 183/255}, {1, 1, 1})

                love.graphics.setColor(u.unpackLove(color))
                love.graphics.rectangle("fill", x*80, y*80, 80, 80)
                love.graphics.setColor(1, 1, 1)
            else
                love.graphics.setColor(0.5, 0.5, 0.5)
                love.graphics.rectangle("fill", x*80, y*80, 80, 80)
                love.graphics.setColor(1, 1, 1)
            end
        end
    end

    love.graphics.print(score, 16, 16)
end

function love.keypressed(key)
    if key == "c" then
        board = createBoard(boardX, boardY)
    end
    if key == "o" then
        cardsPicked = {}
    end
end

function love.mousepressed(x, y)
    -- Checking if mouse clicked in any of the cards
    if not mainclock.waitingForResults then
        for _x, row in pairs(board) do
            for _y, card in pairs(row) do
                if (card.clicked == false) and (card.active  == true) and (x >= _x*80 and x < _x*80+80) and (y >= _y*80 and y < _y*80+80) then
                    table.insert(cardsPicked, {content=card.content, x=_x, y=_y})
                    card.clicked = true
                end
            end
        end
    end
end