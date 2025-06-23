local LetterBoxes = require("src.letter_boxes")
local GameState = require("src.game_state")
local question_selector = require("src/utils/question_selector")
local keyboard = require("src.virtual_keyboard")
local randomSeed = require("src.utils.random_seed")
local itemsCore = require("src.items.core")
local GameScene = {}
GameScene.__index = GameScene

-- Font cache (performance improvement)
local fontCache = {
    font14 = love.graphics.newFont("assets/fonts/ShareTechMono-Regular.ttf", 14),
    font18 = love.graphics.newFont("assets/fonts/ShareTechMono-Regular.ttf", 18),
    font22 = love.graphics.newFont("assets/fonts/ShareTechMono-Regular.ttf", 22),
    font24 = love.graphics.newFont("assets/fonts/ShareTechMono-Regular.ttf", 24),
    font36 = love.graphics.newFont("assets/fonts/ShareTechMono-Regular.ttf", 36),
}

local typeSound = love.audio.newSource("assets/sounds/type.mp3", "static")
local failSound = love.audio.newSource("assets/sounds/fail.mp3", "static")
local successSound = love.audio.newSource("assets/sounds/success.wav", "static")
local powerupSound = love.audio.newSource("assets/sounds/powerup.wav", "static")

local function playTypeSound()
    if typeSound then
        typeSound:stop()
        typeSound:play()
    end
end

local function playFailSound()
    if failSound then
        failSound:stop()
        failSound:play()
    end
end

local function playSuccessSound()
    if successSound then
        successSound:stop()
        successSound:play()
    end
end

local function playPowerupSound()
    if powerupSound then
        powerupSound:stop()
        powerupSound:play()
    end
end

local function resetGameState()
    GameState.reset()
end

function GameScene:new(allQuestions, round, seed)
    if seed then
        local numSeed = 0
        for i = 1, #seed do
            numSeed = numSeed + string.byte(seed, i)
        end
        math.randomseed(numSeed)
    end
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
    keyboard.setAvailableLetters(q.answer, self.seedNum)
end

-- Animação de letra indo do teclado para a caixa de resposta
local activeAnimations = {}

local function startLetterAnimation(letter, fromX, fromY, toX, toY, duration)
    table.insert(activeAnimations, {
        letter = letter,
        fromX = fromX,
        fromY = fromY,
        toX = toX,
        toY = toY,
        duration = duration or 0.25,
        elapsed = 0
    })
end

function GameScene:update(dt)
    if self.state ~= "playing" then return end
    self.timeLeft = self.timeLeft - dt
    if self.timeLeft <= 0 then
        self.state = "gameover"
    end
    -- Atualiza animações
    for i = #activeAnimations, 1, -1 do
        local anim = activeAnimations[i]
        anim.elapsed = anim.elapsed + dt
        if anim.elapsed >= anim.duration then
            if anim.onFinish then anim.onFinish() end
            table.remove(activeAnimations, i)
        end
    end
end

function GameScene:draw()
    local screenW, screenH = love.graphics.getDimensions()
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.setColor(1, 1, 1)
    local seedText = "Seed: " .. tostring(self.seed or "-")
    love.graphics.setFont(fontCache.font14)
    love.graphics.print(seedText, screenW - 120, screenH - 30)
    -- Botão de pular (durante a partida)
    if self.state == "playing" and (GameState.jumps or 0) > 0 then
        local btnW, btnH = 120, 36
        local btnX = screenW - btnW - 16
        local btnY = 60 -- Ajustado para ficar abaixo do tempo
        love.graphics.setColor(0.2, 0.6, 1)
        love.graphics.rectangle("fill", btnX, btnY, btnW, btnH, 8, 8)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(fontCache.font18)
        love.graphics.printf("Pular (" .. tostring(GameState.jumps) .. ")", btnX, btnY + (btnH - fontCache.font18:getHeight())/2, btnW, "center")
    end
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
        -- Itens aleatórios
        if not self.shopItems then
            self.shopItems = itemsCore.getRandomItems(2)
            self.rerollCost = 20
        end
        local itemW, itemH = 340, 70
        for idx, itemName in ipairs(self.shopItems) do
            local item = itemsCore.items[itemName]
            local itemY = screenH/2 - 80 + (idx-1)*100
            local itemX = (screenW - itemW) / 2
            love.graphics.setColor(0.15, 0.15 + 0.05*idx, 0.2)
            love.graphics.rectangle("fill", itemX, itemY, itemW, itemH, 14, 14)
            love.graphics.setColor(1, 1, 1)
            love.graphics.setFont(fontCache.font24)
            love.graphics.printf(item.title or itemName, itemX, itemY + 10, itemW, "center")
            love.graphics.setFont(fontCache.font18)
            love.graphics.printf("Custa: " .. tostring(item.price or 0) .. " moedas", itemX, itemY + 40, itemW, "center")
        end
        -- Botão reroll
        local rerollW, rerollH = 180, 48
        local rerollX = (screenW - rerollW) / 2
        local rerollY = screenH/2 + 140
        love.graphics.setColor(0.3, 0.3, 0.7)
        love.graphics.rectangle("fill", rerollX, rerollY, rerollW, rerollH, 10, 10)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(fontCache.font22)
        love.graphics.printf("Reroll (" .. tostring(self.rerollCost or 20) .. ")", rerollX, rerollY + (rerollH - fontCache.font22:getHeight())/2, rerollW, "center")
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
    -- Desenha animações de letras
    for _, anim in ipairs(activeAnimations) do
        local t = math.min(anim.elapsed / anim.duration, 1)
        local x = anim.fromX + (anim.toX - anim.fromX) * t
        local y = anim.fromY + (anim.toY - anim.fromY) * t
        love.graphics.setColor(1, 1, 1, 1-t*0.3)
        local animFont = love.graphics.newFont("assets/fonts/ShareTechMono-Regular.ttf", 28)
        love.graphics.setFont(animFont)
        love.graphics.print(anim.letter, x, y)
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fontCache.font22)
    local roundText = self.round or 1
    love.graphics.print("Round: " .. tostring(roundText), 32, 20)
    love.graphics.setFont(fontCache.font18)
    love.graphics.setColor(1, 1, 0.2)
    love.graphics.print("Time: " .. math.ceil(self.timeLeft), screenW - 120, 20)
    love.graphics.setColor(1, 1, 1)
end

function GameScene:mousepressed(x, y, button)
    -- Botão de pular SEMPRE deve ser verificado antes de qualquer return!
    if self.state == "playing" and (GameState.jumps or 0) > 0 then
        local screenW = love.graphics.getWidth()
        local btnW, btnH = 120, 36
        local btnX = screenW - btnW - 16
        local btnY = 60
        if x >= btnX and x <= btnX + btnW and y >= btnY and y <= btnY + btnH then
            if self.currentIndex < #self.questions then
                GameState.jumps = GameState.jumps - 1
                self.currentIndex = self.currentIndex + 1
                self:setCurrentQuestion()
                keyboard.resetLetters(self.seedNum)
            else
                GameState.jumps = GameState.jumps - 1
                self:finishRound()
                self.state = "next_round"
            end
            return -- IMPORTANTE: retorna imediatamente após processar o clique
        end
    end
    if self.state == "gameover" then
        local screenW, screenH = love.graphics.getDimensions()
        local btnW, btnH = 220, 48
        local btnX = (screenW - btnW) / 2
        local btnY = screenH/2 + 40
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
        if not self.shopItems then 
            self.shopItems = itemsCore.getRandomItems(2)
            self.rerollCost = 20
        end
        local itemW, itemH = 340, 70
        for idx, itemName in ipairs(self.shopItems) do
            local itemY = screenH/2 - 80 + (idx-1)*100
            local itemX = (screenW - itemW) / 2
            if x >= itemX and x <= itemX + itemW and y >= itemY and y <= itemY + itemH then
                local bought = itemsCore.buyItem(itemName)
                if bought then
                    table.remove(self.shopItems, idx)
                end
                return
            end
        end
        -- Botão reroll
        local rerollW, rerollH = 180, 48
        local rerollX = (screenW - rerollW) / 2
        local rerollY = screenH/2 + 140
        if x >= rerollX and x <= rerollX + rerollW and y >= rerollY and y <= rerollY + rerollH then
            if GameState.coins >= (self.rerollCost or 20) then
                GameState.coins = GameState.coins - (self.rerollCost or 20)
                self.rerollCost = (self.rerollCost or 20) + 10
                self.shopItems = itemsCore.getRandomItems(2)
            end
            return
        end
        -- Botão próximo round
        local btnW, btnH = 320, 48
        local btnX = (screenW - btnW) / 2
        local btnY = screenH - btnH - 32
        if x >= btnX and x <= btnX + btnW and y >= btnY and y <= btnY + btnH then
            self.shopItems = nil
            self.rerollCost = nil
            self:goToNextRound()
            return
        end
        return
    end
    if self.state ~= "playing" then return end
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    -- Clique nas letras (agora suporta múltiplas linhas e índice global correto)
    local keyRects = keyboard.getKeyRects(screenW, screenH)
    for _, key in ipairs(keyRects) do
        if key.letter and key.x and key.y and key.w and key.h and key.index then
            if x >= key.x and x <= key.x + key.w and y >= key.y and y <= key.y + key.h then
                -- Calcula destino da animação (primeira caixa vazia)
                local boxRects = self.letterBoxesComponent:getBoxRects()
                local targetIdx = nil
                for i, _ in ipairs(self.letterBoxesComponent.letters) do
                    if self.letterBoxesComponent.letters[i] == "" then
                        targetIdx = i
                        break
                    end
                end
                if targetIdx then
                    local toRect = boxRects[targetIdx]
                    local fromX = key.x + key.w/2
                    local fromY = key.y + key.h/2
                    local toX = toRect.x + toRect.w/2
                    local toY = toRect.y + toRect.h/2
                    keyboard.useLetter(key.letter, key.index)
                    startLetterAnimation(key.letter, fromX, fromY, toX, toY, 0.25)
                end
                -- Após a animação, preenche a resposta normalmente
                activeAnimations[#activeAnimations].onFinish = function()
                    self.letterBoxesComponent:insertLetter(key.letter)
                    playTypeSound()
                    self:checkAnswer()
                end
                return
            end
        end
    end
    local boxRects = self.letterBoxesComponent:getBoxRects()
    for i, rect in ipairs(boxRects) do
        if x >= rect.x and x <= rect.x + rect.w and y >= rect.y and y <= rect.y + rect.h then
            local removed = self.letterBoxesComponent:removeLetterAt(i)
            if removed then
                keyboard.restoreLetter(removed)
            end
            return
        end
    end
    -- Botão de apagar
    local eraseX, eraseY, eraseW, eraseH = keyboard.getEraseButtonRect(screenW, screenH)
    if x >= eraseX and x <= eraseX + eraseW and y >= eraseY and y <= eraseY + eraseH then
        local removed = self.letterBoxesComponent:removeLastLetter()
        if removed then
            keyboard.restoreLetter(removed)
        end
        return
    end
end

function GameScene:keypressed(key)
    if self.state ~= "playing" then return end
    if key == "backspace" then
        local removed = self.letterBoxesComponent:removeLastLetter()
        if removed then
            keyboard.restoreLetter(removed)
        end
        return
    end
    if #key == 1 then
        local upper = string.upper(key)
        -- Só permite digitar se a letra está disponível no teclado virtual
        local found = false
        for i, obj in ipairs(keyboard.lettersState or {}) do
            if obj.letter == upper and obj.available then
                found = true
                obj.available = false
                break
            end
        end
        if found then
            self.letterBoxesComponent:insertLetter(upper)
            playTypeSound()
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
        playSuccessSound()
        self.correctCount = self.correctCount + 1
        if self.correctCount >= 3 then
            self:finishRound()
            self.state = "next_round"
        else
            self.currentIndex = self.currentIndex + 1
            self:setCurrentQuestion()
            keyboard.resetLetters(self.seedNum)
        end
    else
        playFailSound()
        self.letterBoxesComponent:resetWithFirstLetter()
        keyboard.resetLetters(self.seedNum)
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
    GameState.roundTime = math.max(10, GameState.roundTime - GameState.deacreaseTimePerRound)
    self.timeLeft = GameState.roundTime
    self.state = "playing"
    self.questions = self:selectQuestionsForRound()
    self:setCurrentQuestion()
    self.shopItems = nil -- reseta para sortear novos itens na próxima loja
end

return GameScene
