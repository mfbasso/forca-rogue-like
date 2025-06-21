local Defaults = {
    showFirstLetter = false,
    repeatQuestions = false,
    coins = 0,
    roundTime = 5,
    plusTimeBought = false,
    deacreaseTimePerRound = 5,
}

local GameState = Defaults

local function resetGame() 
    for k, v in pairs(Defaults) do
        GameState[k] = v
    end
end

Defaults.reset = resetGame

return GameState
