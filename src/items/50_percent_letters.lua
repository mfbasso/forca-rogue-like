local GameState = require("src.game_state")

local item = {}

item.name = "show_50_percent_letters"
item.title = "Revela 50% das letras"
item.price = 300
item.sell_price = 150
item.type = "rare"
item.description = "Revela 50% das letras da resposta correta."
item.shouldRegister = true

item.active = function()
  GameState.showFiftyPercent = true
end

item.inactive = function()
  GameState.showFiftyPercent = false
end

return item