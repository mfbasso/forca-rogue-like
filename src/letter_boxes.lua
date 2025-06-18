-- Componente para exibir caixas de letras de uma palavra
local LetterBoxes = {}
LetterBoxes.__index = LetterBoxes

function LetterBoxes:new(word, screenWidth, y)
    local obj = setmetatable({}, self)
    obj.word = word or ""
    obj.letters = {}
    obj.y = y or 0
    obj.screenWidth = screenWidth or 380
    obj.boxSize = 48
    obj.boxSpacing = 12
    obj:setWord(word)
    return obj
end

function LetterBoxes:setWord(word)
    self.word = word or ""
    self.letters = {}
    for i = 1, #self.word do
        self.letters[i] = ""
    end
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
        if self.letters[i] ~= "" then
            self.letters[i] = ""
            break
        end
    end
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
    local font = love.graphics.newFont(26)
    for i = 1, n do
        local x = startX + (i - 1) * (boxSize + boxSpacing)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", x, self.y, boxSize, boxSize, 10, 10)
        love.graphics.setColor(0, 0, 0)
        love.graphics.setFont(font)
        local letter = self.letters[i]
        if letter ~= "" then
            love.graphics.print(letter, x + (boxSize - font:getWidth(letter)) / 2, self.y + (boxSize - font:getHeight()) / 2)
        end
    end
    love.graphics.setColor(1, 1, 1)
end

return LetterBoxes
