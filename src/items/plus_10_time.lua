local GameState = require("src.game_state")

local item = {}

item.name = "plus_10_time"
item.title = "+10 segundos"
item.price = 90
item.sell_price = 45
item.type = "uncommon"
item.description = "Aumenta o tempo da rodada em 10 segundos."
item.shouldRegister = false

item.active = function()
  GameState.plusTimeBought = true
  GameState.roundTime = GameState.roundTime + 10
end

item.inactive = function()
  -- No specific action needed when deactivating this item
end

return item