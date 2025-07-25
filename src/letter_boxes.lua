-- Componente para exibir caixas de letras de uma palavra
local LetterBoxes = {}
LetterBoxes.__index = LetterBoxes

function LetterBoxes:new(word, screenWidth, y, showFirstLetter)
    local obj = setmetatable({}, self)
    obj.word = word or ""
    obj.letters = {}
    obj.y = y or 0
    obj.screenWidth = screenWidth or 380
    obj.boxSize = 48
    obj.boxSpacing = 12
    obj.showFirstLetter = showFirstLetter == nil and true or showFirstLetter
    obj:setWord(word, obj.showFirstLetter)
    return obj
end

function LetterBoxes:setWord(word, showFirstLetter)
    self.word = word or ""
    self.letters = {}
    self.showFirstLetter = showFirstLetter == nil and self.showFirstLetter or showFirstLetter
    local GameState = require("src.game_state")
    local idx = 1
    -- Gera as posições fixas uma única vez por palavra
    if not self.fixedPositions or self.lastFixedWord ~= self.word then
        self.fixedPositions = {}
        self.lastFixedWord = self.word
        local revealed = {}
        if GameState.showFiftyPercent then
            local toReveal = math.floor(#self.word / 2)
            local positions = {}
            for i = 1, #self.word do
                if self.word:sub(i, i) ~= " " then
                    table.insert(positions, i)
                end
            end
            -- Usa uma seed baseada na palavra para garantir sempre o mesmo embaralhamento
            local seed = 0
            for i = 1, #self.word do seed = seed + string.byte(self.word, i) end
            local oldRandom = math.random
            math.randomseed(seed)
            for i = #positions, 2, -1 do
                local j = math.random(i)
                positions[i], positions[j] = positions[j], positions[i]
            end
            math.random = oldRandom
            for i = 1, toReveal do
                revealed[positions[i]] = true
            end
        end
        for i = 1, #self.word do
            if GameState.showFiftyPercent and revealed[i] then
                self.fixedPositions[i] = true
            elseif self.showFirstLetter and i == 1 then
                self.fixedPositions[i] = true
            end
        end
    end
    for i = 1, #self.word do
        local c = self.word:sub(i, i)
        if c == " " then
            self.letters[idx] = "_SPACE_"
        elseif self.fixedPositions[i] then
            self.letters[idx] = c
        else
            self.letters[idx] = ""
        end
        idx = idx + 1
    end
end

function LetterBoxes:resetWithFirstLetter()
    self:setWord(self.word, self.showFirstLetter)
end

function LetterBoxes:insertLetter(letter)
    for i = 1, #self.letters do
        if self.letters[i] == "" then
            self.letters[i] = letter
            break
        end
    end
end

function LetterBoxes:removeLastLetter()
    for i = #self.letters, 1, -1 do
        if self.letters[i] ~= "" and self.letters[i] ~= "_SPACE_" and not (self.fixedPositions and self.fixedPositions[i]) then
            local removed = self.letters[i]
            self.letters[i] = ""
            return removed
        end
    end
    return nil
end

function LetterBoxes:getBoxRects()
    local n = #self.letters
    if n == 0 then return {} end
    local maxWidth = self.screenWidth * 0.92
    local boxSize = self.boxSize
    local boxSpacing = self.boxSpacing
    local totalWidth = n * boxSize + (n - 1) * boxSpacing
    if totalWidth > maxWidth then
        boxSize = math.floor((maxWidth - (n - 1) * boxSpacing) / n)
        if boxSize < 24 then boxSize = 24 end
    end
    local startX = (self.screenWidth - (n * boxSize + (n - 1) * boxSpacing)) / 2
    local rects = {}
    for i = 1, n do
        local x = startX + (i - 1) * (boxSize + boxSpacing)
        rects[i] = {x = x, y = self.y, w = boxSize, h = boxSize}
    end
    return rects
end

function LetterBoxes:removeLetterAt(index)
    if self.letters[index] ~= "" and self.letters[index] ~= "_SPACE_" and not (self.fixedPositions and self.fixedPositions[index]) then
        local removed = self.letters[index]
        self.letters[index] = ""
        return removed
    end
    return nil
end

function LetterBoxes:draw()
    local n = #self.letters
    if n == 0 then return end
    -- Calcula tamanho e espaçamento para caber na tela
    local maxWidth = self.screenWidth * 0.92
    local boxSize = self.boxSize
    local boxSpacing = self.boxSpacing
    local totalWidth = n * boxSize + (n - 1) * boxSpacing
    if totalWidth > maxWidth then
        boxSize = math.floor((maxWidth - (n - 1) * boxSpacing) / n)
        if boxSize < 24 then boxSize = 24 end
    end
    local startX = (self.screenWidth - (n * boxSize + (n - 1) * boxSpacing)) / 2
    local font = love.graphics.newFont("assets/fonts/ShareTechMono-Regular.ttf", 26)
    for i = 1, n do
        local x = startX + (i - 1) * (boxSize + boxSpacing)
        if self.letters[i] == "_SPACE_" then
           
        else
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("fill", x, self.y, boxSize, boxSize, 10, 10)
            love.graphics.setColor(0, 0, 0)
            love.graphics.setFont(font)
            local letter = self.letters[i]
            if letter ~= "" then
                love.graphics.print(letter, x + (boxSize - font:getWidth(letter)) / 2, self.y + (boxSize - font:getHeight()) / 2)
            end
        end
    end
    love.graphics.setColor(1, 1, 1)
end

return LetterBoxes
