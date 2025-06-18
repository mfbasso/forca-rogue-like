math.randomseed(os.time() + tonumber(tostring(os.clock()):reverse():sub(1,6)))
math.random(); math.random(); math.random()

local function randomSeedString(len)
    local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local s = ''
    for i = 1, len do
        local idx = math.random(1, #chars)
        s = s .. chars:sub(idx, idx)
    end
    return s
end

return {
    randomSeedString = randomSeedString
}
