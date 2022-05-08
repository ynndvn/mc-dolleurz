dofile("./commons.lua")
rednet.open("left")

local bridge = getPeripheral("meBridge")
local monitor = getPeripheral("monitor")
local detector = getPeripheral("playerDetector")

local user = ""
local width, height = monitor.getSize()
local modalWidth = math.ceil(width * .65)
local modalHeight = 10
local prevCoords = { 1, math.ceil(height / 2) }
local nextCoords = { width, math.ceil(height / 2) }
local buyCoords = { 0, 0 }
local minusPlus = {1, 10, 64, 100, 1000}

local modalButtons = {
  okCoords = initButtonCoords(),
  cancelCoords = initButtonCoords(),
  plus = {},
  minus = {}
}
for i, v in pairs(minusPlus) do
  modalButtons.plus[v] = initButtonCoords()
  modalButtons.minus[v] = initButtonCoords()
end
local pageNum = 1
local offers = {}
local currentDisplay = "list"
local transactionQty = 0
local transactionItem = {}

function getClosestPlayer() 
  local players = detector.getPlayersInRange(2)
  if #players == 0 then
    user = ""
  else
    user = players[1]
  end
end

function parseDisplayName(n)
  -- "    [Cobblestone]"
  n = trim(n)
  -- "[Cobblestone]"
  return string.sub(n, 2, #n - 1)
  -- "Cobblestone"
end

function displayLine(item, qtyLen, nameLen)
    local price = ""
    local buyText = ""
    if item.price ~= nil then
      price = item.price .. " F/u"
      buyText = "ACHETER"
    end
    prompt(monitor, "|" .. centerText(item.displayName, nameLen + 2) .. "|" .. centerText("" .. item.amount, qtyLen + 2) .. "|" .. centerText(price, 10) .. "|" .. centerText(buyText, 10) .. "|", true)
end

function displayPage (items, pageNumber)
  local nameLen = #"Nom"
  local qtyLen = #"Stock"
  if items[pageNumber] == nil then
    return
  end

  for i,item in pairs(items[pageNumber]) do
      if #item.displayName > nameLen then
        nameLen = math.min(#item.displayName, 25)
      end 
      if #("" .. item.amount) > qtyLen then
        qtyLen = #("" .. item.amount)
      end 
  end
  local firstLine = "|" .. centerText("Nom", nameLen + 2) .. "|" .. centerText("Stock", qtyLen + 2) .. "|   Prix   | Échanges |"
  local buyStart = #firstLine + math.ceil((width - #firstLine) / 2) - 9
  buyCoords = {buyStart, buyStart + #"ACHETER" - 1}
  prompt(monitor, firstLine, true)
  prompt(monitor, string.rep("-", #firstLine), true)
  for i,item in pairs(items[pageNumber]) do
    displayLine(item, qtyLen, nameLen)
  end
end

function drawListOverlay()
  getClosestPlayer()
  if pageNum > 1 then
    monitor.setCursorPos(prevCoords[1], prevCoords[2])
    monitor.write("<")
  end
  if pageNum < #offers then
    monitor.setCursorPos(nextCoords[1], nextCoords[2])
    monitor.write(">")
  end
  monitor.setCursorPos(1, height)
  monitor.write(centerText(user .. " - Page " .. pageNum .. "/" .. #offers, width))
  monitor.setCursorPos(1, 1)
end

function getOffers ()
  local result = get("/offers")
  local lines = textutils.unserializeJSON(result.readAll())
  h = height - 3
  local stocks = bridge.listItems()
  table.sort(stocks, function (left, right)
    return right.displayName > left.displayName
  end)
  local returnValue = {}

  for i,s in pairs(sortObject(stocks)) do
    local index = i - 1
    for j,line in pairs(lines) do
      if line.name == s.name then
        s.price = line.price
      end
    end
    if returnValue[math.floor(index / h) + 1] == nil then 
      returnValue[math.floor(index / h) + 1] = {} 
    end
    table.insert(returnValue[math.floor(index / h) + 1], {
      price = s.price,
      displayName = parseDisplayName(s.displayName),
      name = s.name,
      amount = s.amount
    })
  end
  return returnValue
end

function getModalCoords() 
  local topLeft = {math.ceil((width - modalWidth) / 2), math.ceil((height - modalHeight) / 2)}
  return { 
    topLeft = topLeft,
    bottomRight = {topLeft[1] + modalWidth, topLeft[2] + modalHeight}
  }
end

function placePlus(qty, modalCoords, i) 
  local len = #("" .. qty)
  modalButtons.plus[qty] = {
    left = { modalCoords.topLeft[1] + math.floor(modalWidth / 4) - len, modalCoords.topLeft[2] + i + 2 },
    right = { modalCoords.topLeft[1] + math.floor(modalWidth / 4), modalCoords.topLeft[2] + i + 2 },
  }
end

function placeMinus(qty, modalCoords, i)
  local len = #("" .. qty)
  modalButtons.minus[qty] = {
    left = { modalCoords.topLeft[1] + math.floor(modalWidth / 4 * 3), modalCoords.topLeft[2] + i + 2 },
    right = { modalCoords.topLeft[1] + math.floor(modalWidth / 4 * 3) + len, modalCoords.topLeft[2] + i + 2 },
  }
end

function setModalButtonsCoords()
  local modalCoords = getModalCoords()
  -- Le "-1" est là pour #"OK"/2.
  modalButtons.okCoords = {
    left = { modalCoords.topLeft[1] + math.floor(modalWidth / 4) - 1, modalCoords.topLeft[2] + modalHeight},
    right = { modalCoords.topLeft[1] + math.floor(modalWidth / 4), modalCoords.topLeft[2] + modalHeight},
  }
  -- Pareil pour "-3" et "Cancel"
  modalButtons.cancelCoords = {
    left = { modalCoords.topLeft[1] + math.floor(modalWidth / 4 * 3) - 3, modalCoords.topLeft[2] + modalHeight},
    right = { modalCoords.topLeft[1] + math.floor(modalWidth / 4 * 3) + 2, modalCoords.topLeft[2] + modalHeight},
  }
  local i = 0
  for v in ipairs(minusPlus) do
    i = i + 1
    placePlus(minusPlus[v], modalCoords, i)
  end
  i = 0
  for v in ipairs(minusPlus) do
    i = i + 1
    placeMinus(minusPlus[v], modalCoords, i)
  end
end

function refresh ()
  offers = getOffers()
  cl(monitor)
  setModalButtonsCoords()
  monitor.setTextScale(1)
  displayPage(offers, pageNum)
  drawListOverlay()
end

function handlePrice()
  local modalCoords = getModalCoords()
  local price = (transactionQty * transactionItem.price) .. "F"
  local x = math.ceil((modalCoords.topLeft[1] + modalCoords.bottomRight[1]) / 2) - math.ceil(#price / 2)
  local y = math.ceil((modalCoords.topLeft[2] + modalCoords.bottomRight[2]) / 2)
  local qtyCoords = { left = { x, y - 1 } }
  local priceCoords = { left = { x, y + 1 } }
  writeText(monitor, qtyCoords, "" .. transactionQty, colors.lightBlue)
  writeText(monitor, priceCoords, price, colors.lightBlue)
end

function reloadBuyModal()
  currentDisplay = "modal"
  local currHeight = 0
  local modalStartWidth = math.ceil((width - modalWidth) / 2)
  monitor.setCursorPos(modalStartWidth, math.ceil((height - modalHeight) / 2))
  
  monitor.write(string.rep("-", modalWidth))
  for i=0, modalHeight, 1 do
    currWidth, currHeight = monitor.getCursorPos()
    monitor.setCursorPos(modalStartWidth, currHeight + 1)
    if i == 0 then 
      monitor.write("|" .. centerText(transactionItem.displayName .. " (" .. transactionItem.price .. " F/u)", modalWidth - 2) .. "|")
    else
      monitor.write("|" .. string.rep(" ", modalWidth - 2) .. "|")
    end
  end
  monitor.setCursorPos(modalStartWidth, currHeight + 1)
  monitor.write(string.rep("-", modalWidth))
  writeText(monitor, modalButtons.okCoords, "OK")
  writeText(monitor, modalButtons.cancelCoords, "Cancel")
  table.sort(minusPlus)
  for i in ipairs(minusPlus) do
    writeText(monitor, modalButtons.plus[minusPlus[i]], "+" .. minusPlus[i], colors.lime)
    writeText(monitor, modalButtons.minus[minusPlus[i]], "-" .. minusPlus[i], colors.red)
  end
  handlePrice()
  monitor.setCursorPos(1, 1)
end

function updateQuantity (newQty)
  transactionQty = math.min(math.max(newQty, 0), transactionItem.amount)
  reloadBuyModal()
end

function displayError(err)
  print(err)
  writeText(monitor, {left = {1, height}}, centerText(err, width))
end

function closeModal() 
  currentDisplay = "list"
  transactionQty = 0
  transactionItem = {}
  refresh()
end

function buy ()
  if user == "" then
    displayError("Rapproche toi du détecteur de joueur pelo")
    return
  end
  local userBalance = tonumber(get("/players/" .. user .. "/balance").readAll())
  if (userBalance) < transactionQty * transactionItem.price then
    displayError("Il te manque de la thune pelo (T'as " .. userBalance .. " Floydies)")
    return
  end
  post("/offers/" .. transactionItem.name .. "/buy", '{"amount": ' .. transactionQty .. ', "userId": "' .. user .. '"}')
  bridge.exportItem({name= transactionItem.name, count=transactionQty}, "UP")
  rednet.broadcast("reload", reloadProtocol)
  closeModal()
end

refresh()

while true do
  local event, side, xPos, yPos = os.pullEvent()
  if event == "monitor_touch" then
    if currentDisplay == "list" then
      local item = offers[pageNum][yPos - 2]
      if pageNum > 1 and xPos == prevCoords[1] and yPos == prevCoords[2] then
        pageNum = pageNum - 1
        refresh()
      elseif pageNum < #offers and xPos == nextCoords[1] and yPos == nextCoords[2] then
        pageNum = pageNum + 1
        refresh()
      elseif yPos > 2 and yPos <= (#offers[pageNum] + 2) and item.price ~= nil then
        if xPos >= buyCoords[1] and xPos <= buyCoords[2] then
          transactionItem = item
          reloadBuyModal()
        end
      end
    elseif currentDisplay == "modal" then
      if isWithinCoords(xPos, yPos, modalButtons.cancelCoords) then
        closeModal()
      end
      if isWithinCoords(xPos, yPos, modalButtons.okCoords) then
        buy()
      end
      for i in pairs(sortObject(modalButtons.plus)) do
        if isWithinCoords(xPos, yPos, modalButtons.plus[i]) then
          updateQuantity(transactionQty + i)
        end
      end
      for i in pairs(sortObject(modalButtons.minus)) do
        if isWithinCoords(xPos, yPos, modalButtons.minus[i]) then
          updateQuantity(transactionQty - i)
        end
      end
    end
    drawListOverlay()
  elseif event == "rednet_message" then
    eventName = yPos
    if eventName == "reload_buy" then
      refresh()
    end
  end
end

