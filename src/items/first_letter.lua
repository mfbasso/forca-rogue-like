local GameState = require("src.game_state")

local item = {}

item.name = "first_letter"
item.title = "Primeira letra"
item.price = 180
item.sell_price = 90
item.type = "rare"
item.description = "Revela a primeira letra da resposta correta."
item.shouldRegister = true

item.active = function()
  GameState.showFirstLetter = true
end

item.inactive = function()
  GameState.showFirstLetter = false
end

return item