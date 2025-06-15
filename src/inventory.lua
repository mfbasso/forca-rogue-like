-- Inventário do jogador
local Inventory = {}

function Inventory:new()
    local obj = {itens = {}}
    setmetatable(obj, self)
    self.__index = self
    return obj
end

return Inventory
