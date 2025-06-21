local GameState = require("src.game_state")

local item = {}

item.name = "round_50_percent_decrease"
item.title = "Tempo cai 50% mais devagar"
item.price = 240
item.sell_price = 120
item.type = "rare"
item.description = "Reduz o tempo da rodada em 50% menos do que o normal."
item.shouldRegister = true

item.active = function()
  GameState.deacreaseTimePerRound = GameState.deacreaseTimePerRound / 2
end

item.inactive = function()
  GameState.deacreaseTimePerRound = GameState.deacreaseTimePerRound * 2
end

return item