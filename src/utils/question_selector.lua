local questions = require("src/questions")

local function get_probabilities_for_round(round)
    if round >= 10 then
        return { [10] = 1.0 }
    end
    local configs = {
        [1] = { [1]=0.8, [2]=0.15, [3]=0.05 },
        [2] = { [2]=0.7, [1]=0.1, [3]=0.15, [4]=0.05 },
        [3] = { [3]=0.6, [2]=0.15, [4]=0.2, [1]=0.05 },
        [4] = { [4]=0.6, [3]=0.15, [5]=0.2, [2]=0.05 },
        [5] = { [5]=0.6, [4]=0.15, [6]=0.2, [3]=0.05 },
        [6] = { [6]=0.6, [5]=0.15, [7]=0.2, [4]=0.05 },
        [7] = { [7]=0.6, [6]=0.15, [8]=0.2, [5]=0.05 },
        [8] = { [8]=0.6, [7]=0.15, [9]=0.2, [6]=0.05 },
        [9] = { [9]=0.6, [8]=0.15, [10]=0.2, [7]=0.05 },
    }
    return configs[round] or { [1]=1.0 }
end

local function weighted_random_choice(weights)
    local sum = 0
    for _, w in pairs(weights) do sum = sum + w end
    local r = math.random() * sum
    local acc = 0
    for k, w in pairs(weights) do
        acc = acc + w
        if r <= acc then return k end
    end
    return next(weights)
end

local function select_question(round, seed)
    if seed then math.randomseed(seed) end
    local probs = get_probabilities_for_round(round)
    local levels = {}
    for lvl, _ in pairs(probs) do table.insert(levels, lvl) end
    local chosen_level = weighted_random_choice(probs)
    local pool = {}
    for _, q in ipairs(questions) do
        if q.level == chosen_level then table.insert(pool, q) end
    end
    if #pool == 0 then
        for _, q in ipairs(questions) do table.insert(pool, q) end
    end
    return pool[math.random(#pool)]
end

return {
    select_question = select_question
}
