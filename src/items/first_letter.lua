local GameState = require("src.game_state")

local item = {}

item.name = "first_letter"
item.title = "Primeira letra"
item.price = 40
item.sell_price = 20
item.type = "common"

item.active = function()
  GameState.showFirstLetter = true
end

item.inactive = function()
  GameState.showFirstLetter = false
end

return item