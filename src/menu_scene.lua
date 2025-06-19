local MenuScene = {}
MenuScene.__index = MenuScene

function MenuScene:new(onPlay)
    local obj = setmetatable({}, self)
    obj.onPlay = onPlay
    return obj
end

function MenuScene:draw()
    local screenW, screenH = love.graphics.getDimensions()
    love.graphics.setBackgroundColor(0, 0, 0)
    local font = love.graphics.newFont("assets/fonts/ShareTechMono-Regular.ttf", 44)
    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Forca Rogue-like", 0, screenH/2-120, screenW, "center")
    local btnW, btnH = 220, 60
    local btnX = (screenW - btnW) / 2
    local btnY = screenH/2 + 10
    love.graphics.setColor(0.2, 0.2, 1)
    love.graphics.rectangle("fill", btnX, btnY, btnW, btnH, 12, 12)
    love.graphics.setColor(1, 1, 1)
    local btnFont = love.graphics.newFont("assets/fonts/ShareTechMono-Regular.ttf", 28)
    love.graphics.setFont(btnFont)
    love.graphics.printf("Jogar", btnX, btnY + (btnH - btnFont:getHeight())/2, btnW, "center")
end

function MenuScene:mousepressed(x, y, button)
    local screenW, screenH = love.graphics.getDimensions()
    local btnW, btnH = 220, 60
    local btnX = (screenW - btnW) / 2
    local btnY = screenH/2 + 10
    if x >= btnX and x <= btnX + btnW and y >= btnY and y <= btnY + btnH then
        if self.onPlay then self.onPlay() end
    end
end

return MenuScene
