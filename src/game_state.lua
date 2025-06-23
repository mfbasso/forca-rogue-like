local Defaults = {
    showFirstLetter = false,
    showFiftyPercent = false,
    repeatQuestions = false,
    jumps = 3,
    coins = 0,
    roundTime = 120,
    plusTimeBought = false,
    deacreaseTimePerRound = 10,
    bougthItems = {},
}

local GameState = {}
for k, v in pairs(Defaults) do
    if type(v) == "table" then
        GameState[k] = {}
        for k2, v2 in pairs(v) do
            GameState[k][k2] = v2
        end
    else
        GameState[k] = v
    end
end

local function resetGame() 
    for k, v in pairs(Defaults) do
        if type(v) == "table" then
            GameState[k] = {}
            for k2, v2 in pairs(v) do
                GameState[k][k2] = v2
            end
        else
            GameState[k] = v
        end
    end
end

GameState.reset = resetGame

return GameState
