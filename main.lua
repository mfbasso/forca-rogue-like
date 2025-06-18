local GameScene = require("src.game_scene")
local currentScene

function love.load()
    if not keyboard then
        keyboard = require("src.virtual_keyboard")
    end
    local questions = {
        {question = "Plural de animais que miam", answer = "GATOS"},
        {question = "Maior planeta do sistema solar", answer = "JUPITER"},
        {question = "Cor do céu em um dia claro", answer = "AZUL"}
    }
    currentScene = GameScene:new(questions)
end

function love.draw()
    if currentScene and currentScene.draw then
        currentScene:draw()
    end
end

function love.update(dt)
    if currentScene and currentScene.update then
        currentScene:update(dt)
    end
end

function love.mousepressed(x, y, button)
    if currentScene and currentScene.mousepressed then
        currentScene:mousepressed(x, y, button)
    end
end
