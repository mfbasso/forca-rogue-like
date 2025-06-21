local GameState = require("src.game_state")

local item = {}

item.name = "plus_5_time"
item.title = "+5 segundos"
item.price = 60
item.sell_price = 30
item.type = "common"
item.description = "Aumenta o tempo da rodada em 5 segundos."
item.shouldRegister = false

item.active = function()
  GameState.plusTimeBought = true
  GameState.roundTime = GameState.roundTime + 5
end

item.inactive = function()
  -- No specific action needed when deactivating this item
end

return item