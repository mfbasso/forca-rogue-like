-- Lista de palavras e helpers
local WordList = {}

WordList.words = {
    "lua", "roguelike", "forca", "jogo", "aventura"
}

function WordList:getRandomWord()
    return self.words[math.random(#self.words)]
end

return WordList
