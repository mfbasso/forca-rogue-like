local backgroundMusic

local function playBackgroundMusic()
    if not backgroundMusic then
        backgroundMusic = love.audio.newSource("assets/sounds/neon_reverie.mp3", "stream")
        backgroundMusic:setLooping(true)
        backgroundMusic:setVolume(0.5)
        backgroundMusic:play()
    elseif not backgroundMusic:isPlaying() then
        backgroundMusic:play()
    end
end

return {
    playBackgroundMusic = playBackgroundMusic
}
