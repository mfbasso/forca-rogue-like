local GameState = require("src.game_state")

local items = {
  first_letter = require("src.items.first_letter"),
  plus_time = require("src.items.plus_time"),
}

local function buyItem(itemName)
  local item = items[itemName]
  if not item then return false end
  if GameState.coins < item.price then return false end
  GameState.coins = GameState.coins - item.price
  GameState.bougthItems[itemName] = true
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

local function weightedTypePick()
  local total = 0
  for _, prob in pairs(typeProbabilities) do
    total = total + prob
  end
  local r = math.random() * total
  local acc = 0
  for type, prob in pairs(typeProbabilities) do
    acc = acc + prob
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

