local LetterBoxes = require("src.letter_boxes")
local GameState = require("src.game_state")
local question_selector = require("src/utils/question_selector")
local keyboard = require("src.virtual_keyboard")
local randomSeed = require("src.utils.random_seed")
local GameScene = {}
GameScene.__index = GameScene

-- Font cache (performance improvement)
local fontCache = {
    font14 = love.graphics.newFont(14),
    font18 = love.graphics.newFont(18),
    font22 = love.graphics.newFont(22),
    font24 = love.graphics.newFont(24),
    font36 = love.graphics.newFont(36),
}

local function resetGameState()
    GameState.coins = 0
    GameState.showFirstLetter = false
    GameState.plusTimeBought = false
    GameState.roundTime = 30
end

function GameScene:new(allQuestions, round, seed)
    local obj = setmetatable({}, self)
    obj.allQuestions = allQuestions
    obj.round = round or 1
    obj.seed = seed or randomSeed.randomSeedString(6)
    obj.usedQuestions = {}
    obj.seedNum = 0
    for i = 1, #obj.seed do
        obj.seedNum = obj.seedNum + string.byte(obj.seed, i)
    end
    obj.questions = obj:selectQuestionsForRound()
    obj.currentIndex = 1
    obj.correctCount = 0
    obj.timeLeft = GameState.roundTime
    obj.letterBoxesComponent = nil
    obj:setCurrentQuestion()
    obj.state = "playing"
    return obj
end

function GameScene:selectQuestionsForRound()
    local questions = {}
    local tries = 0
    local allowRepeat = GameState.repeatQuestions
    while #questions < 3 and tries < 100 do
        local q = question_selector.select_question(self.round or 1, self.seedNum + #questions * 100 + tries * 1000)
        local key = q.question .. "|" .. q.answer .. "|" .. tostring(q.level)
        if allowRepeat or not self.usedQuestions[key] then
            if not allowRepeat then
                self.usedQuestions[key] = true
            end
            table.insert(questions, q)
        end
        tries = tries + 1
    end
    return questions
end

function GameScene:setCurrentQuestion()
    local q = self.questions and self.questions[self.currentIndex] or nil
    if not q then
        if self.state ~= "gameover" and self.state ~= "next_round" then
            self.state = "next_round"
        end
        return
    end
    local screenW = love.graphics.getWidth()
    self.currentQuestion = q.question
    self.currentAnswer = q.answer
    self.letterBoxesComponent = LetterBoxes:new(q.answer, screenW, 300, GameState.showFirstLetter)
end

function GameScene:update(dt)
    if self.state ~= "playing" then return end
    self.timeLeft = self.timeLeft - dt
    if self.timeLeft <= 0 then
        self.state = "gameover"
    end
end

function GameScene:draw()
    local screenW, screenH = love.graphics.getDimensions()
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.setColor(1, 1, 1)
    local seedText = "Seed: " .. tostring(self.seed or "-")
    love.graphics.setFont(fontCache.font14)
    love.graphics.print(seedText, screenW - 120, screenH - 30)
    if self.state == "gameover" then
        love.graphics.setFont(fontCache.font36)
        love.graphics.setColor(1, 0.2, 0.2)
        love.graphics.printf("Game Over", 0, screenH/2-60, screenW, "center")
        love.graphics.setFont(fontCache.font22)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Você chegou até o round " .. tostring(self.round or 1), 0, screenH/2-10, screenW, "center")
        local btnW, btnH = 220, 48
        local btnX = (screenW - btnW) / 2
        local btnY = screenH/2 + 40
        love.graphics.setColor(0.2, 0.2, 1)
        love.graphics.rectangle("fill", btnX, btnY, btnW, btnH, 12, 12)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(fontCache.font24)
        love.graphics.printf("Jogar novamente", btnX, btnY + (btnH - fontCache.font24:getHeight())/2, btnW, "center")
        return
    elseif self.state == "next_round" then
        love.graphics.setBackgroundColor(0, 0, 0)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(fontCache.font36)
        love.graphics.printf("Loja", 0, screenH/2-160, screenW, "center")
        local coinsText = "Moedas: " .. tostring(GameState.coins or 0)
        love.graphics.setFont(fontCache.font22)
        love.graphics.print(coinsText, 32, 20)
        -- Item: Primeira letra
        if not GameState.showFirstLetter then
            local itemY = screenH/2 - 40
            local itemW, itemH = 340, 70
            local itemX = (screenW - itemW) / 2
            love.graphics.setColor(0.15, 0.15, 0.2)
            love.graphics.rectangle("fill", itemX, itemY, itemW, itemH, 14, 14)
            love.graphics.setColor(1, 1, 1)
            love.graphics.setFont(fontCache.font24)
            love.graphics.printf("Primeira letra", itemX, itemY + 10, itemW, "center")
            love.graphics.setFont(fontCache.font18)
            love.graphics.printf("Custa: 40 moedas", itemX, itemY + 40, itemW, "center")
        end
        -- Item: +10 segundos
        if GameState.roundTime < 60 and not GameState.plusTimeBought then
            local plusTimeY = screenH/2 + 50
            local plusTimeW, plusTimeH = 340, 70
            local plusTimeX = (screenW - plusTimeW) / 2
            love.graphics.setColor(0.15, 0.2, 0.15)
            love.graphics.rectangle("fill", plusTimeX, plusTimeY, plusTimeW, plusTimeH, 14, 14)
            love.graphics.setColor(1, 1, 1)
            love.graphics.setFont(fontCache.font24)
            love.graphics.printf("+10 segundos", plusTimeX, plusTimeY + 10, plusTimeW, "center")
            love.graphics.setFont(fontCache.font18)
            love.graphics.printf("Custa: 60 moedas", plusTimeX, plusTimeY + 40, plusTimeW, "center")
        end
        -- Botão próximo round
        local btnW, btnH = 320, 48
        local btnX = (screenW - btnW) / 2
        local btnY = screenH - btnH - 32
        love.graphics.setColor(0.2, 0.2, 1)
        love.graphics.rectangle("fill", btnX, btnY, btnW, btnH, 12, 12)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(fontCache.font24)
        love.graphics.printf("Ir para o próximo round", btnX, btnY + (btnH - fontCache.font24:getHeight())/2, btnW, "center")
        return
    elseif self.state == "win" then
        love.graphics.setFont(fontCache.font36)
        love.graphics.setColor(0.2, 1, 0.2)
        love.graphics.printf("Congratulations!", 0, screenH/2-40, screenW, "center")
        return
    end
    love.graphics.setFont(fontCache.font22)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Moedas: " .. tostring(GameState.coins), 32, 60)
    -- Quebra o texto da pergunta para caber na tela
    local questionText = self.currentQuestion or ""
    local maxWidth = screenW - 64
    love.graphics.printf(questionText, 32, 180, maxWidth, "center")
    self.letterBoxesComponent:draw()
    keyboard.draw(screenW, screenH)
    love.graphics.setFont(fontCache.font18)
    love.graphics.setColor(1, 1, 0.2)
    love.graphics.print("Time: " .. math.ceil(self.timeLeft), screenW - 120, 20)
    love.graphics.setColor(1, 1, 1)
    local roundText = self.round or 1
    love.graphics.print("Round: " .. tostring(roundText), 32, 20)
end

function GameScene:mousepressed(x, y, button)
    if self.state == "gameover" then
        local screenW, screenH = love.graphics.getDimensions()
        local btnW, btnH = 220, 48
        local btnX = (screenW - btnW) / 2
        local btnY = screenH/2 + 10
        if x >= btnX and x <= btnX + btnW and y >= btnY and y <= btnY + btnH then
            resetGameState()
            self.round = 1
            self.currentIndex = 1
            self.correctCount = 0
            self.timeLeft = GameState.roundTime
            self.state = "playing"
            self.seed = randomSeed.randomSeedString(6)
            self.usedQuestions = {}
            self.seedNum = 0
            for i = 1, #self.seed do
                self.seedNum = self.seedNum + string.byte(self.seed, i)
            end
            self.questions = self:selectQuestionsForRound()
            self:setCurrentQuestion()
            return
        end
        return
    elseif self.state == "next_round" then
        local screenW, screenH = love.graphics.getDimensions()
        -- Item: Primeira letra
        local itemW, itemH = 340, 70
        local itemX = (screenW - itemW) / 2
        local itemY = screenH/2 - 40
        if x >= itemX and x <= itemX + itemW and y >= itemY and y <= itemY + itemH then
            if GameState.coins >= 40 and not GameState.showFirstLetter then
                GameState.coins = GameState.coins - 40
                GameState.showFirstLetter = true
            end
            return
        end
        -- Item: +10 segundos
        local plusTimeW, plusTimeH = 340, 70
        local plusTimeX = (screenW - plusTimeW) / 2
        local plusTimeY = screenH/2 + 50
        if x >= plusTimeX and x <= plusTimeX + plusTimeW and y >= plusTimeY and y <= plusTimeY + plusTimeH then
            if GameState.coins >= 60 and not GameState.plusTimeBought then
                GameState.coins = GameState.coins - 60
                GameState.roundTime = GameState.roundTime + 10
                GameState.plusTimeBought = true
            end
            return
        end
        -- Botão próximo round
        local btnW, btnH = 320, 48
        local btnX = (screenW - btnW) / 2
        local btnY = screenH - btnH - 32
        if x >= btnX and x <= btnX + btnW and y >= btnY and y <= btnY + btnH then
            self:goToNextRound()
            return
        end
        return
    end
    if self.state ~= "playing" then return end
    local screenW, screenH = love.graphics.getDimensions()
    local kb = keyboard
    local numRows = #kb.rows
    local totalHeight = numRows * kb.boxSize + (numRows - 1) * kb.boxSpacing
    -- Raise the keyboard by 10% of the screen (igual ao desenho)
    local startY = screenH - totalHeight - 32 - (screenH * 0.1)
    for rowIdx, row in ipairs(kb.rows) do
        local boxes = #row
        local totalWidth = boxes * kb.boxSize + (boxes - 1) * kb.boxSpacing
        local startX = (screenW - totalWidth) / 2
        local yk = startY + (rowIdx - 1) * (kb.boxSize + kb.boxSpacing)
        for i = 1, boxes do
            local xk = startX + (i - 1) * (kb.boxSize + kb.boxSpacing)
            if x >= xk and x <= xk + kb.boxSize and y >= yk and y <= yk + kb.boxSize then
                local letter = row[i]
                self.letterBoxesComponent:insertLetter(letter)
                self:checkAnswer()
                return
            end
        end
    end
    local eraseX, eraseY, eraseW, eraseH = keyboard.getEraseButtonRect(screenW, screenH)
    if x >= eraseX and x <= eraseX + eraseW and y >= eraseY and y <= eraseY + eraseH then
        self.letterBoxesComponent:removeLastLetter()
        return
    end
end

function GameScene:keypressed(key)
    if self.state ~= "playing" then return end
    if key == "backspace" then
        self.letterBoxesComponent:removeLastLetter()
        return
    end
    if #key == 1 then
        local upper = string.upper(key)
        if upper:match("^[A-ZÁÉÍÓÚÃÕÇ]$") then
            self.letterBoxesComponent:insertLetter(upper)
            self:checkAnswer()
        end
    end
end

function GameScene:checkAnswer()
    local guess = ""
    for i = 1, #self.letterBoxesComponent.letters do
        local l = self.letterBoxesComponent.letters[i]
        if l ~= "_SPACE_" then
            guess = guess .. (l or "")
        end
    end
    local answerNoSpaces = (self.currentAnswer or ""):gsub(" ", "")
    if #guess < #answerNoSpaces then return end
    if guess == answerNoSpaces then
        self.correctCount = self.correctCount + 1
        if self.correctCount >= 3 then
            self:finishRound()
            self.state = "next_round"
        else
            self.currentIndex = self.currentIndex + 1
            self:setCurrentQuestion()
        end
    else
        self.letterBoxesComponent:resetWithFirstLetter()
    end
end

function GameScene:finishRound()
    local coinsEarned = math.max(0, math.ceil(self.timeLeft))
    GameState.coins = (GameState.coins or 0) + coinsEarned
end

function GameScene:goToNextRound()
    self.round = (self.round or 1) + 1
    self.currentIndex = 1
    self.correctCount = 0
    GameState.roundTime = math.max(10, GameState.roundTime - 3)
    self.timeLeft = GameState.roundTime
    self.state = "playing"
    self.questions = self:selectQuestionsForRound()
    self:setCurrentQuestion()
end

return GameScene
