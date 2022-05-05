dofile("./commons.lua")
rednet.open("left")

monitor = getPeripheral("monitor")
detector = getPeripheral("playerDetector")
bridge = getPeripheral("meBridge")
blockReader = getPeripheral("blockReader")

local width, height = monitor.getSize()
local user = ""
local items = {}
local offers = {}
local pageNum = 1
local prevCoords = { 1, math.ceil(height / 2) }
local nextCoords = { width, math.ceil(height / 2) }
local reloadCoords = {0, 0}
local sellCoords = {0, 0}

function getClosestPlayer() 
  local players = detector.getPlayersInRange(2)
  if #players == 0 then
    user = ""
  else
    user = players[1]
  end
end

function readItems()
  local itemsList = {}
  local name = blockReader.getBlockName()
  local content = blockReader.getBlockData()

  if content == nil then
    return
  end
  for k,v in ipairs(content.Items) do
    if itemsList[v.id] == nil then
      itemsList[v.id] = { count = v.Count }
    else
      itemsList[v.id] = { count = itemsList[v.id].count + v.Count }
    end
  end
  items = {}
  local h = height - 3
  local i = 0
  for name,s in pairs(sortObject(itemsList)) do
    i = i + 1
    local index = i - 1
    if items[math.floor(index / h) + 1] == nil then 
      items[math.floor(index / h) + 1] = {} 
    end
    table.insert(items[math.floor(index / h) + 1], {
      name = name,
      prettyName = split(name, ":")[2],
      count = s.count
    })
  end
end

function setPrices()
  local result = get("/offers")
  offers = textutils.unserializeJSON(result.readAll())
  for i, offer in pairs(offers) do
    for pageNum, page in pairs(items) do
      for index, item in pairs(page) do
        if item.name == offer.name then
          item.price = offer.price
        end
      end
    end
  end
end

function displayItems()
  local nameLen = #"Item"
  local countLen = #"Quantité"
  local priceLen = #"INCONNU"
  if #items == 0 then
    return
  end
  for i, details in pairs(items[pageNum]) do
    nameLen = getMinMax(#(details.prettyName), nameLen, 30)
    countLen = getMinMax(#("" .. details.count), countLen, 12)
    details.priceStr = "INCONNU"
    if details.price ~= nil then
      details.priceStr = "" .. (details.count * details.price * sellBuyRatio) .. " F"
    end
    priceLen = getMinMax(#(details.priceStr), priceLen, 12)
  end
  prompt(monitor, "|" .. centerText("Item", nameLen + 2) .. "|" .. centerText("Quantité", countLen + 2) .. "|" .. centerText("Prix", priceLen + 2) .. "|", true)
  prompt(monitor, "|" .. string.rep("-", nameLen + 2) .. "|" .. string.rep("-",  countLen + 2) .. "|" .. string.rep("-", priceLen + 2) .. "|", true)
  for name, details in pairs(items[pageNum]) do
    prompt(monitor, "|" .. centerText(details.prettyName, nameLen + 2) .. "|" .. centerText("" .. details.count, countLen + 2) .. "|" .. centerText(details.priceStr, priceLen + 2) .. "|", true)
  end
end

function displayOverlay()
  if pageNum > 1 then
    monitor.setCursorPos(prevCoords[1], prevCoords[2])
    monitor.write("<")
  end
  if pageNum < #items then
    monitor.setCursorPos(nextCoords[1], nextCoords[2])
    monitor.write(">")
  end
  monitor.setCursorPos(1, height)
  local bottomLine = user .. " - Page " .. pageNum .. "/" .. #items .. " - RELOAD - VENDRE"
  monitor.write(centerText(bottomLine, width))
  local reloadStart = math.ceil((width - #bottomLine) / 2) + #bottomLine - #"RELOAD - VENDRE" + 1
  local sellStart = math.ceil((width - #bottomLine) / 2) + #bottomLine - #"VENDRE" + 1
  reloadCoords = {reloadStart, reloadStart + #"RELOAD" - 1}
  sellCoords = {sellStart, sellStart + #"VENDRE" - 1}
  monitor.setCursorPos(1, 1)
end

function reloadItemsFromInput()
  readItems()
  setPrices()
end

function redrawPage()
  cl(monitor)
  displayItems()
  displayOverlay()
end

function sell()
  local totalPrice = 0
  for pageNum, page in pairs(items) do
      for index, item in pairs(page) do
        if item.price ~= nil then
          bridge.importItem({
            name = item.name,
            count = item.count
          }, "EAST")
          totalPrice = totalPrice + item.count * item.price * sellBuyRatio
        end
      end
  end
  post("/players/" .. user .. "/balance/add", '{"amount": ' .. totalPrice .. '}')
  rednet.broadcast("reload", reloadProtocol)
  rednet.broadcast("reload", "reload_buy")
  refresh()
end

function refresh()
  getClosestPlayer(detector)
  readItems()
  setPrices()
  redrawPage()
end

refresh()

while true do
  local event, side, xPos, yPos = os.pullEvent()
  
  if event == "monitor_touch" then
    if pageNum > 1 and xPos == prevCoords[1] and yPos == prevCoords[2] then
      pageNum = pageNum - 1
      redrawPage()
    elseif pageNum < #items and xPos == nextCoords[1] and yPos == nextCoords[2] then
      pageNum = pageNum + 1
      redrawPage()
    elseif yPos == height then
      if xPos >= reloadCoords[1] and xPos <= reloadCoords[2] then
        refresh()
      elseif xPos >= sellCoords[1] and xPos <= sellCoords[2] then
        sell()
      end
    end
  end
end