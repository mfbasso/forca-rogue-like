-- Virtual keyboard for the game screen
local keyboard = {}

keyboard.rows = {
    {"Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"},
    {"A", "S", "D", "F", "G", "H", "J", "K", "L"},
    {"Z", "X", "C", "V", "B", "N", "M"}
}
keyboard.boxSize = 32
keyboard.boxSpacing = 4

function keyboard.draw(screenWidth, screenHeight)
    local numRows = #keyboard.rows
    local totalHeight = numRows * keyboard.boxSize + (numRows - 1) * keyboard.boxSpacing
    -- Suba o teclado em 30% da tela
    local startY = screenHeight - totalHeight - 32 - (screenHeight * 0.1)
    for rowIdx, row in ipairs(keyboard.rows) do
        local boxes = #row
        local totalWidth = boxes * keyboard.boxSize + (boxes - 1) * keyboard.boxSpacing
        local startX = (screenWidth - totalWidth) / 2
        local y = startY + (rowIdx - 1) * (keyboard.boxSize + keyboard.boxSpacing)
        for i = 1, boxes do
            local x = startX + (i - 1) * (keyboard.boxSize + keyboard.boxSpacing)
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("fill", x, y, keyboard.boxSize, keyboard.boxSize, 8, 8)
            love.graphics.setColor(0, 0, 0)
            local letterFont = love.graphics.newFont(20)
            love.graphics.setFont(letterFont)
            local letter = row[i]
            local letterWidth = letterFont:getWidth(letter)
            local letterHeight = letterFont:getHeight()
            love.graphics.print(letter, x + (keyboard.boxSize - letterWidth) / 2, y + (keyboard.boxSize - letterHeight) / 2)
        end
    end
    -- Botão de apagar
    local eraseX, eraseY, eraseW, eraseH = keyboard.getEraseButtonRect(screenWidth, screenHeight)
    love.graphics.setColor(1, 0.3, 0.3)
    love.graphics.rectangle("fill", eraseX, eraseY, eraseW, eraseH, 8, 8)
    love.graphics.setColor(1, 1, 1)
    local eraseFont = love.graphics.newFont(18)
    love.graphics.setFont(eraseFont)
    local eraseText = "Apagar"
    local eraseTextW = eraseFont:getWidth(eraseText)
    local eraseTextH = eraseFont:getHeight()
    love.graphics.print(eraseText, eraseX + (eraseW - eraseTextW) / 2, eraseY + (eraseH - eraseTextH) / 2)
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.setColor(1, 1, 1)
end

function keyboard.getEraseButtonRect(screenWidth, screenHeight)
    local eraseW, eraseH = 90, 36
    local eraseX = (screenWidth - eraseW) / 2
    local numRows = #keyboard.rows
    local totalHeight = numRows * keyboard.boxSize + (numRows - 1) * keyboard.boxSpacing
    -- Suba o botão de apagar em 10% da tela
    local eraseY = screenHeight - 24 - (screenHeight * 0.1)
    return eraseX, eraseY, eraseW, eraseH
end

return keyboard
