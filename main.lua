local GameScene = require("src.game_scene")
local MenuScene = require("src.menu_scene")
local currentScene
local allQuestions = require("src.questions")

local function shuffle(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
end

local function startGame()
    local questionsCopy = {}
    for i, q in ipairs(allQuestions) do
        questionsCopy[i] = q
    end
    shuffle(questionsCopy)
    local questions = {questionsCopy[1], questionsCopy[2], questionsCopy[3]}
    currentScene = GameScene:new(questions)
end

function love.load()
    if not keyboard then
        keyboard = require("src.virtual_keyboard")
    end
    currentScene = MenuScene:new(startGame)
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

function love.keypressed(key)
    if currentScene and currentScene.keypressed then
        currentScene:keypressed(key)
    end
end
