local LetterBoxes = require("src.letter_boxes")
local GameScene = {}
GameScene.__index = GameScene

function GameScene:new(questions)
    local obj = setmetatable({}, self)
    obj.questions = questions
    obj.currentIndex = 1
    obj.correctCount = 0
    obj.timeLeft = 30
    obj.letterBoxesComponent = nil
    obj:setCurrentQuestion()
    obj.state = "playing"
    return obj
end

function GameScene:setCurrentQuestion()
    local q = self.questions[self.currentIndex]
    local LetterBoxes = require("src.letter_boxes")
    local screenW = love.graphics.getWidth()
    self.currentQuestion = q.question
    self.currentAnswer = q.answer
    self.letterBoxesComponent = LetterBoxes:new(q.answer, screenW, 300)
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
    if self.state == "gameover" then
        local font = love.graphics.newFont(36)
        love.graphics.setFont(font)
        love.graphics.setColor(1, 0.2, 0.2)
        love.graphics.printf("Game Over", 0, screenH/2-60, screenW, "center")
        -- Draw Try Again button
        local btnW, btnH = 220, 48
        local btnX = (screenW - btnW) / 2
        local btnY = screenH/2 + 10
        love.graphics.setColor(0.2, 0.2, 1)
        love.graphics.rectangle("fill", btnX, btnY, btnW, btnH, 12, 12)
        love.graphics.setColor(1, 1, 1)
        local btnFont = love.graphics.newFont(24)
        love.graphics.setFont(btnFont)
        love.graphics.printf("Tentar novamente", btnX, btnY + (btnH - btnFont:getHeight())/2, btnW, "center")
        return
    elseif self.state == "win" then
        local font = love.graphics.newFont(36)
        love.graphics.setFont(font)
        love.graphics.setColor(0.2, 1, 0.2)
        love.graphics.printf("Parabéns!", 0, screenH/2-40, screenW, "center")
        return
    end
    local font = love.graphics.newFont(22)
    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(self.currentQuestion, 32, 180)
    self.letterBoxesComponent:draw()
    keyboard.draw(screenW, screenH)
    local timerFont = love.graphics.newFont(18)
    love.graphics.setFont(timerFont)
    love.graphics.setColor(1, 1, 0.2)
    love.graphics.print("Tempo: " .. math.ceil(self.timeLeft), screenW - 120, 20)
end

function GameScene:mousepressed(x, y, button)
    if self.state == "gameover" then
        local screenW, screenH = love.graphics.getDimensions()
        local btnW, btnH = 220, 48
        local btnX = (screenW - btnW) / 2
        local btnY = screenH/2 + 10
        if x >= btnX and x <= btnX + btnW and y >= btnY and y <= btnY + btnH then
            self.currentIndex = 1
            self.correctCount = 0
            self.timeLeft = 30
            self.state = "playing"
            self:setCurrentQuestion()
            return
        end
        return
    end
    if self.state ~= "playing" then return end
    local screenW, screenH = love.graphics.getDimensions()
    local kb = keyboard
    local numRows = #kb.rows
    local totalHeight = numRows * kb.boxSize + (numRows - 1) * kb.boxSpacing
    local startY = screenH - totalHeight - 32
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
    if self.state == "gameover" then
        local btnW, btnH = 220, 48
        local btnX = (screenW - btnW) / 2
        local btnY = screenH/2 + 10
        if x >= btnX and x <= btnX + btnW and y >= btnY and y <= btnY + btnH then
            -- Reset game
            local newGame = GameScene:new(self.questions)
            newGame.correctCount = 0
            newGame.currentIndex = 1
            newGame.timeLeft = 30
            newGame.state = "playing"
            newGame:setCurrentQuestion()
            return newGame
        end
    end
end

function GameScene:checkAnswer()
    local guess = ""
    for i = 1, #self.letterBoxesComponent.letters do
        guess = guess .. (self.letterBoxesComponent.letters[i] or "")
    end
    if #guess < #self.currentAnswer then return end
    if guess == self.currentAnswer then
        self.correctCount = self.correctCount + 1
        if self.correctCount >= #self.questions then
            self.state = "win"
        else
            self.currentIndex = self.currentIndex + 1
            self:setCurrentQuestion()
        end
    else
        self.letterBoxesComponent:setWord(self.currentAnswer)
    end
end

return GameScene
