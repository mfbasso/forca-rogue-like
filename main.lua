function drawGameScreen()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    love.graphics.setBackgroundColor(0, 0, 0)

    -- Question text
    local question = "Plural de animais que miam"
    local font = love.graphics.newFont(22)
    love.graphics.setFont(font)
    local textWidth = font:getWidth(question)
    local textHeight = font:getHeight()
    local textX = (screenWidth - textWidth) / 2
    local textY = 220
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(question, textX, textY)

    -- Letter boxes
    local boxSize = 48
    local boxSpacing = 12
    local boxes = 5
    local totalWidth = boxes * boxSize + (boxes - 1) * boxSpacing
    local startX = (screenWidth - totalWidth) / 2
    local startY = textY + textHeight * 2
    for i = 1, boxes do
        local x = startX + (i - 1) * (boxSize + boxSpacing)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", x, startY, boxSize, boxSize, 10, 10)
        love.graphics.setColor(0, 0, 0)
        if i == 1 then
            local letterFont = love.graphics.newFont(26)
            love.graphics.setFont(letterFont)
            local letter = "G"
            local letterWidth = letterFont:getWidth(letter)
            local letterHeight = letterFont:getHeight()
            love.graphics.print(letter, x + (boxSize - letterWidth) / 2, startY + (boxSize - letterHeight) / 2)
            love.graphics.setFont(font)
        end
    end
    love.graphics.setColor(1, 1, 1)

    -- Desenha o teclado virtual na parte inferior
    if not keyboard then
        keyboard = require("src.virtual_keyboard")
    end
    keyboard.draw(screenWidth, screenHeight)
end

function love.draw()
    drawGameScreen()
end
