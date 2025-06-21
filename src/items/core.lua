local GameState = require("src.game_state")

local items = {
  first_letter = require("src.items.first_letter"),
  plus_5_time = require("src.items.plus_5_time"),
  plus_10_time = require("src.items.plus_10_time"),
  plus_60_time = require("src.items.plus_60_time"),
  round_50_percent_decrease = require("src.items.round_50_percent_decrease"),
}

local function buyItem(itemName)
  local item = items[itemName]
  if not item then return false end
  if GameState.coins < item.price then return false end
  GameState.coins = GameState.coins - item.price
  if item.shouldRegister ~= false then
    GameState.bougthItems[itemName] = true
  end
  item.active()
  return true
end

local function sellItem(itemName)
  local item = items[itemName]
  if not item then return false end
  if not GameState.bougthItems[itemName] then return false end
  GameState.coins = GameState.coins + item.sell_price
  GameState.bougthItems[itemName] = nil
  item.inactive()
  return true
end

local typeProbabilities = {
  legendary = 0.01,
  rare = 0.09,
  uncommon = 0.2,
  common = 0.70
}

local typeOrder = {"legendary", "rare", "uncommon", "common"}

local function shuffle(tbl)
  for i = #tbl, 2, -1 do
    local j = math.random(i)
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
end

local function weightedTypePick()
  local shuffledTypeOrder = {unpack(typeOrder)}
  shuffle(shuffledTypeOrder)
  local total = 0
  for _, type in ipairs(shuffledTypeOrder) do
    total = total + (typeProbabilities[type] or 0)
  end
  local r = math.random() * total
  local acc = 0
  for _, type in ipairs(shuffledTypeOrder) do
    acc = acc + (typeProbabilities[type] or 0)
    if r <= acc then
      return type
    end
  end
  return "common"
end

local function getRandomItems(numItems)
  local availableItemsByType = {legendary = {}, rare = {}, uncommon = {}, common = {}}
  for name, item in pairs(items) do
    if not GameState.bougthItems[name] then
      local t = item.type or "common"
      if availableItemsByType[t] then
        table.insert(availableItemsByType[t], name)
      end
    end
  end
  -- Embaralha os pools de cada tipo para garantir aleatoriedade
  for _, pool in pairs(availableItemsByType) do
    for i = #pool, 2, -1 do
      local j = math.random(i)
      pool[i], pool[j] = pool[j], pool[i]
    end
  end
  print("Available items by type:")
  for t, list in pairs(availableItemsByType) do
    print(t .. ":", table.concat(list, ", "))
  end
  local selectedItems = {}
  for i = 1, numItems do
    local chosenType = weightedTypePick()
    print("Chosen type for position " .. i .. ": " .. chosenType)
    local pool = availableItemsByType[chosenType]
    if #pool == 0 then
      print("No items available for type " .. chosenType .. ", trying common...")
      pool = availableItemsByType["common"]
    end
    if #pool > 0 then
      local idx = math.random(#pool)
      print("Selected item for position " .. i .. ": " .. pool[idx])
      table.insert(selectedItems, pool[idx])
      table.remove(pool, idx)
    else
      print("No items available for position " .. i)
    end
  end
  print("Final selected items:", table.concat(selectedItems, ", "))
  return selectedItems
end

return {
  items = items,
  buyItem = buyItem,
  sellItem = sellItem,
  getRandomItems = getRandomItems,
}

