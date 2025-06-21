local GameState = require("src.game_state")

local item = {}

item.name = "plus_60_time"
item.title = "+60 segundos"
item.price = 320
item.sell_price = 120
item.type = "legendary"
item.description = "Aumenta o tempo da rodada em 60 segundos."
item.shouldRegister = false

item.active = function()
  GameState.plusTimeBought = true
  GameState.roundTime = GameState.roundTime + 60
end

item.inactive = function()
  -- No specific action needed when deactivating this item
end

return item