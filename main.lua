local love = require("love")

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
    -- Creating the 'board':
    boardX = 4
    boardY = 4
    board = createBoard(boardX, boardY)

    cardsPicked = {}
    score = 0

    -- Loading assets:
    midFont = love.graphics.newFont("assets/fonts/04B_03_.TTF", 64)

    love.graphics.setFont(midFont)
end

function love.update()
    if #cardsPicked == 2 then
        if cardsPicked[1].content == cardsPicked[2].content then
            score = score + 5
            board[cardsPicked[1].x][cardsPicked[1].y].active = false
            board[cardsPicked[2].x][cardsPicked[2].y].active = false
        else
            score = score - 1
            board[cardsPicked[1].x][cardsPicked[1].y].clicked = false
            board[cardsPicked[2].x][cardsPicked[2].y].clicked = false
        end
    end
end

function love.draw()
    for x, row in pairs(board) do
        for y, card in pairs(row) do
            if card.active and card.clicked then
                love.graphics.print(card.content, x*96+96/4, y*96+96/4)
            elseif card.active and not card.clicked then
                love.graphics.rectangle("fill", x*96, y*96, 96, 96)
            else
                love.graphics.setColor(0.5, 0.5, 0.5)
                love.graphics.rectangle("fill", x*96, y*96, 96, 96)
                love.graphics.setColor(1, 1, 1)
            end
        end
    end
end

function love.keypressed(key)
    if key == "c" then
        board = createBoard(boardX, boardY)
    end
end

function love.mousepressed(x, y)
    -- Checking if mouse clicked in any of the cards
    for _x, row in pairs(board) do
        for _y, card in pairs(row) do
            if (card.clicked == false) and (card.active  == true) and (x >= _x*96 and x <= _x*96+96) and (y >= _y*96 and y <= _y*96+96) then
                table.insert(cardsPicked, {content=card.content, x=_x, y=_y})
                card.clicked = true
            end
        end
    end
end