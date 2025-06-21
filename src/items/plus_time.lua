local GameState = require("src.game_state")

local item = {}

item.name = "plus_time"
item.title = "+10 segundos"
item.price = 60
item.sell_price = 30
item.type = "uncommon"

item.active = function()
  GameState.plusTimeBought = true
  GameState.roundTime = GameState.roundTime + 10
end

item.inactive = function()
  -- No specific action needed when deactivating this item
end

return item