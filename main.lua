-- Estado dos blocos de letras
if not letterBoxes then
    letterBoxes = {"", "", "", "", ""}
end
if not letterAnimations then
    letterAnimations = {nil, nil, nil, nil, nil}
end

function love.load()
    if not keyboard then
        keyboard = require("src.virtual_keyboard")
    end
end

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
        local letterFont = love.graphics.newFont(26)
        love.graphics.setFont(letterFont)
        local letter = letterBoxes[i] ~= "" and letterBoxes[i] or ""
        if letter ~= "" then
            local scale = 1
            if letterAnimations[i] then
                scale = letterAnimations[i].scale
            end
            local letterWidth = letterFont:getWidth(letter) * scale
            local letterHeight = letterFont:getHeight() * scale
            love.graphics.push()
            love.graphics.translate(x + boxSize / 2, startY + boxSize / 2)
            love.graphics.scale(scale, scale)
            love.graphics.print(letter, -letterFont:getWidth(letter)/2, -letterFont:getHeight()/2)
            love.graphics.pop()
        end
        love.graphics.setFont(font)
    end
    love.graphics.setColor(1, 1, 1)

    -- Desenha o teclado virtual na parte inferior
    if not keyboard then
        keyboard = require("src.virtual_keyboard")
    end
    keyboard.draw(screenWidth, screenHeight)
end

function love.update(dt)
    -- Atualiza animações das letras
    for i = 1, #letterAnimations do
        local anim = letterAnimations[i]
        if anim then
            anim.time = anim.time + dt
            if anim.time < anim.duration then
                anim.scale = 0.5 + 0.5 * math.sin((anim.time/anim.duration)*math.pi)
            else
                anim.scale = 1
                letterAnimations[i] = nil
            end
        end
    end
end

function isInsideBox(x, y, bx, by, bw, bh)
    return x >= bx and x <= bx + bw and y >= by and y <= by + bh
end

function love.mousepressed(x, y, button)
    if button == 1 then
        -- Garante que o teclado virtual está carregado
        if not keyboard then
            keyboard = require("src.virtual_keyboard")
        end
        local screenWidth, screenHeight = love.graphics.getDimensions()
        local kb = keyboard
        local numRows = #kb.rows
        local totalHeight = numRows * kb.boxSize + (numRows - 1) * kb.boxSpacing
        local startY = screenHeight - totalHeight - 32
        for rowIdx, row in ipairs(kb.rows) do
            local boxes = #row
            local totalWidth = boxes * kb.boxSize + (boxes - 1) * kb.boxSpacing
            local startX = (screenWidth - totalWidth) / 2
            local yk = startY + (rowIdx - 1) * (kb.boxSize + kb.boxSpacing)
            for i = 1, boxes do
                local xk = startX + (i - 1) * (kb.boxSize + kb.boxSpacing)
                if isInsideBox(x, y, xk, yk, kb.boxSize, kb.boxSize) then
                    local letter = row[i]
                    -- Coloca a letra no primeiro bloco vazio
                    for j = 1, #letterBoxes do
                        if letterBoxes[j] == "" then
                            letterBoxes[j] = letter
                            letterAnimations[j] = {scale = 0.5, time = 0, duration = 0.25}
                            break
                        end
                    end
                    return
                end
            end
        end
        -- Botão de apagar
        local eraseX, eraseY, eraseW, eraseH = keyboard.getEraseButtonRect(screenWidth, screenHeight)
        if isInsideBox(x, y, eraseX, eraseY, eraseW, eraseH) then
            for j = #letterBoxes, 1, -1 do
                if letterBoxes[j] ~= "" then
                    letterBoxes[j] = ""
                    letterAnimations[j] = nil
                    break
                end
            end
            return
        end
    end
end

function love.draw()
    drawGameScreen()
end
