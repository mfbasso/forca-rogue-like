-- Lógica do jogador
local Player = {}

function Player:new()
    local obj = {vidas = 6, letras = {}}
    setmetatable(obj, self)
    self.__index = self
    return obj
end

return Player
