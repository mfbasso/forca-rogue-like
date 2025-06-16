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
    local startY = screenHeight - totalHeight - 32
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
    love.graphics.setColor(1, 1, 1)
end

return keyboard
