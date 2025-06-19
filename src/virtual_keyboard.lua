-- Virtual keyboard for the game screen
local keyboard = {}
local GameState = require("src.game_state")

keyboard.rows = {
    {"Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"},
    {"A", "S", "D", "F", "G", "H", "J", "K", "L"},
    {"Z", "X", "C", "V", "B", "N", "M"}
}
keyboard.boxSize = 32
keyboard.boxSpacing = 4
keyboard.availableLetters = nil
keyboard.originalLetters = nil
keyboard.lettersState = nil

local function seededRandom(seed)
    local m = 2^32
    local a = 1664525
    local c = 1013904223
    local state = seed or os.time()
    return function()
        state = (a * state + c) % m
        return state / m
    end
end

function keyboard.shuffleLetters(seed)
    if not keyboard.originalLetters then return end
    local unpack = unpack -- compatibilidade Lua 5.1
    local letters = {unpack(keyboard.originalLetters)}
    local rand = seededRandom(seed)
    for i = #letters, 2, -1 do
        local j = math.floor(rand() * i) + 1
        letters[i], letters[j] = letters[j], letters[i]
    end
    keyboard.lettersState = {}
    for i, l in ipairs(letters) do
        keyboard.lettersState[i] = {letter = l, available = true}
    end
end

function keyboard.setAvailableLetters(answer, seed)
    -- Cria lista de letras (com repetições, sem espaços)
    local letters = {}
    answer = answer:gsub(" ", "")
    for i = 1, #answer do
        local c = answer:sub(i, i):upper()
        table.insert(letters, c)
    end
    -- Remove a primeira letra se showFirstLetter estiver ativo
    if GameState.showFirstLetter and #letters > 0 then
        table.remove(letters, 1)
    end
    -- Adiciona letras extras aleatórias
    local alphabet = {}
    for i = 65, 90 do table.insert(alphabet, string.char(i)) end -- A-Z
    -- Remove letras já presentes
    local used = {}
    for _, l in ipairs(letters) do used[l] = true end
    -- Gera seed para aleatoriedade
    local rand = seededRandom(seed)
    -- Seleciona de 1 a 4 letras extras
    local numExtras = math.floor(rand() * 4) + 1
    local extras = {}
    local available = {}
    for _, l in ipairs(alphabet) do if not used[l] then table.insert(available, l) end end
    for i = 1, numExtras do
        if #available == 0 then break end
        local idx = math.floor(rand() * #available) + 1
        table.insert(extras, available[idx])
        table.remove(available, idx)
    end
    for _, l in ipairs(extras) do table.insert(letters, l) end
    keyboard.originalLetters = letters
    keyboard.shuffleLetters(seed)
end

function keyboard.resetLetters(seed)
    if keyboard.originalLetters then
        keyboard.shuffleLetters(seed)
    end
end

function keyboard.useLetter(letter, index)
    -- Se index for fornecido, remove exatamente aquele
    if index then
        if keyboard.lettersState and keyboard.lettersState[index] and keyboard.lettersState[index].letter == letter and keyboard.lettersState[index].available then
            keyboard.lettersState[index].available = false
            return
        end
    end
    -- Caso contrário, remove a primeira ocorrência disponível
    for i, obj in ipairs(keyboard.lettersState or {}) do
        if obj.letter == letter and obj.available then
            obj.available = false
            break
        end
    end
end

function keyboard.restoreLetter(letter)
    -- Restaura a primeira ocorrência não disponível
    for i, obj in ipairs(keyboard.lettersState) do
        if obj.letter == letter and not obj.available then
            obj.available = true
            break
        end
    end
end

local function getRows()
    if not keyboard.availableLetters then
        return keyboard.rows
    end
    -- Distribute available letters in up to 3 rows
    local rows = {{}, {}, {}}
    local perRow = math.ceil(#keyboard.availableLetters / 3)
    for i, letter in ipairs(keyboard.availableLetters) do
        local rowIdx = math.ceil(i / perRow)
        table.insert(rows[rowIdx], letter)
    end
    return rows
end

function keyboard.draw(screenWidth, screenHeight)
    local letters = keyboard.lettersState or {}
    local total = #letters
    if total == 0 then return end
    -- Divide as letras em até duas linhas, mantendo a ordem e o índice global
    local rows = {}
    if total > 7 then
        local half = math.ceil(total / 2)
        rows[1] = {}
        rows[2] = {}
        for i = 1, half do table.insert(rows[1], letters[i]) end
        for i = half + 1, total do table.insert(rows[2], letters[i]) end
    else
        rows[1] = letters
    end
    local numRows = #rows
    local boxSize = keyboard.boxSize
    local boxSpacing = keyboard.boxSpacing
    local totalHeight = numRows * boxSize + (numRows - 1) * boxSpacing
    local startY = screenHeight - totalHeight - 32 - (screenHeight * 0.1)
    local font = love.graphics.newFont(20)
    local globalIndex = 1
    for rowIdx, row in ipairs(rows) do
        local boxes = #row
        local totalWidth = boxes * boxSize + (boxes - 1) * boxSpacing
        local startX = (screenWidth - totalWidth) / 2
        local y = startY + (rowIdx - 1) * (boxSize + boxSpacing)
        for i = 1, boxes do
            local obj = row[i]
            if obj and obj.available then
                local x = startX + (i - 1) * (boxSize + boxSpacing)
                love.graphics.setColor(1, 1, 1)
                love.graphics.rectangle("fill", x, y, boxSize, boxSize, 8, 8)
                love.graphics.setColor(0, 0, 0)
                love.graphics.setFont(font)
                local letter = obj.letter
                local letterWidth = font:getWidth(letter)
                local letterHeight = font:getHeight()
                love.graphics.print(letter, x + (boxSize - letterWidth) / 2, y + (boxSize - letterHeight) / 2)
            end
            globalIndex = globalIndex + 1
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
    local y = screenHeight - keyboard.boxSize - 32 - (screenHeight * 0.1)
    local eraseY = y + keyboard.boxSize + 12
    return eraseX, eraseY, eraseW, eraseH
end

-- Retorna uma lista de teclas com posição de tela e índice global
function keyboard.getKeyRects(screenWidth, screenHeight)
    local letters = keyboard.lettersState or {}
    local total = #letters
    if total == 0 then return {} end
    local rows = {}
    if total > 7 then
        local half = math.ceil(total / 2)
        rows[1] = {}
        rows[2] = {}
        for i = 1, half do table.insert(rows[1], letters[i]) end
        for i = half + 1, total do table.insert(rows[2], letters[i]) end
    else
        rows[1] = letters
    end
    local numRows = #rows
    local boxSize = keyboard.boxSize
    local boxSpacing = keyboard.boxSpacing
    local totalHeight = numRows * boxSize + (numRows - 1) * boxSpacing
    local startY = screenHeight - totalHeight - 32 - (screenHeight * 0.1)
    local keyRects = {}
    local globalIndex = 1
    for rowIdx, row in ipairs(rows) do
        local boxes = #row
        local totalWidth = boxes * boxSize + (boxes - 1) * boxSpacing
        local startX = (screenWidth - totalWidth) / 2
        local y = startY + (rowIdx - 1) * (boxSize + boxSpacing)
        for i = 1, boxes do
            local obj = row[i]
            if obj and obj.available then
                local x = startX + (i - 1) * (boxSize + boxSpacing)
                table.insert(keyRects, {
                    letter = obj.letter,
                    index = globalIndex,
                    x = x,
                    y = y,
                    w = boxSize,
                    h = boxSize
                })
            end
            globalIndex = globalIndex + 1
        end
    end
    return keyRects
end

return keyboard
