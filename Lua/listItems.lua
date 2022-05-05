dofile("./commons.lua")
rednet.open("left")

local bridge = getPeripheral("meBridge")
local monitor = getPeripheral("monitor")
local detector = getPeripheral("playerDetector")

local user = ""
local width, height = monitor.getSize()
local modalWidth = math.ceil(width * .65)
local modalHeight = 10
local prevCoords = { 0, 0 }
local nextCoords = { 0, 0 }
local buyCoords = { 0, 0 }
local modalButtons = {
  okCoords = initButtonCoords(),
  cancelCoords = initButtonCoords(),
  plus = sortObject({
    [1] = initButtonCoords(),
    [10] = initButtonCoords(),
    [100] = initButtonCoords(),
    [1000] = initButtonCoords()
  }),
  minus = sortObject({
    [1] = initButtonCoords(),
    [10] = initButtonCoords(),
    [100] = initButtonCoords(),
    [1000] = initButtonCoords()
  })
}
local pageNum = 1
local offers = {}
local currentDisplay = "list"
local transactionQty = 0
local transactionPrice = 0
local transactionItem = {}

function getClosestPlayer() 
  local players = detector.getPlayersInRange(3)
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
    local price = ""
    local buyText = ""
    if item.price ~= nil then
      price = item.price .. " F/u"
      buyText = "ACHETER"
    end
    prompt(monitor, "|" .. centerText(item.displayName, nameLen + 2) .. "|" .. centerText("" .. item.amount, qtyLen + 2) .. "|" .. centerText(price, 10) .. "|" .. centerText(buyText, 10) .. "|", true)
  end
end

function drawListOverlay()
  getClosestPlayer()
  if pageNum > 1 then
    prevCoords = { 1, math.ceil(height / 2) }
    monitor.setCursorPos(prevCoords[1], prevCoords[2])
    monitor.write("<")
  end
  if pageNum < #offers then
    nextCoords = { width, math.ceil(height / 2) }
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

function placePlus(qty, modalCoords) 
  local len = #("" .. qty)
  modalButtons.plus[qty] = {
    left = { modalCoords.topLeft[1] + math.floor(modalWidth / 4) - len, modalCoords.topLeft[2] + len + 2 },
    right = { modalCoords.topLeft[1] + math.floor(modalWidth / 4), modalCoords.topLeft[2] + len + 2 },
  }
end

function placeMinus(qty, modalCoords)
  local len = #("" .. qty)
  modalButtons.minus[qty] = {
    left = { modalCoords.topLeft[1] + math.floor(modalWidth / 4 * 3), modalCoords.topLeft[2] + len + 2 },
    right = { modalCoords.topLeft[1] + math.floor(modalWidth / 4 * 3) + len, modalCoords.topLeft[2] + len + 2 },
  }
end

function calculateButtonCoords()
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
  for i in pairs(modalButtons.plus) do
    placePlus(i, modalCoords)
  end
  for i in pairs(modalButtons.minus) do
    placeMinus(i, modalCoords)
  end
end

function refresh ()
  offers = getOffers()
  cl(monitor)
  calculateButtonCoords()
  monitor.setTextScale(1)
  displayPage(offers, pageNum)
  drawListOverlay()
end

function writeText(coords, text, color)
  if color ~= nil then
    monitor.setTextColor(color)
  end
  monitor.setCursorPos(coords.left[1], coords.left[2])
  monitor.setTextColor(colors.white)
  monitor.write(text)
end

function handlePrice()
  local modalCoords = getModalCoords()
  local price = (transactionQty * transactionItem.price) .. "F"
  local qtyCoords = {
    left = {
      math.ceil((modalCoords.topLeft[1] + modalCoords.bottomRight[1]) / 2) - math.ceil(#price / 2),
      math.ceil((modalCoords.topLeft[2] + modalCoords.bottomRight[2]) / 2) - 1
    }
  }
  local priceCoords = {
    left = {
      math.ceil((modalCoords.topLeft[1] + modalCoords.bottomRight[1]) / 2) - math.ceil(#price / 2),
      math.ceil((modalCoords.topLeft[2] + modalCoords.bottomRight[2]) / 2) + 1
    }
  }
  writeText(qtyCoords, "" .. transactionQty, colors.lightBlue)
  writeText(priceCoords, price, colors.lightBlue)
end

function displayExchangeModal()
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
  writeText(modalButtons.okCoords, "OK")
  writeText(modalButtons.cancelCoords, "Cancel")
  for i in pairs(modalButtons.plus) do
    writeText(modalButtons.plus[i], "+" .. i, colors.lime)
  end
  for i in pairs(modalButtons.minus) do
    writeText(modalButtons.minus[i], "-" .. i, colors.red)
  end
  handlePrice()
  monitor.setCursorPos(1, 1)
end

refresh()

function isWithinCoords (xPos, yPos, coords)
  if xPos >= coords.left[1] 
    and xPos <= coords.right[1] 
    and yPos >= coords.left[2] 
    and yPos <= coords.right[2] then
    return true
  end
  return false
end

function updateQuantity (newQty)
  transactionQty = math.min(math.max(transactionQty - i, 0), transactionItem.amount)
  displayExchangeModal()
end

function displayError(err)
  print(err)
  writeText({left = {1, height}}, centerText(err, width))
end

function buy ()
  print(user)
  if user == "" then
    displayError("Rapproche toi du détecteur de joueur pelo")
    return
  end
  local userBalance = get("/players/" .. user .. "/balance")
  print("Balance : " .. userBalance.readAll())
  if userBalance <
end

while true do
  local event, side, xPos, yPos = os.pullEvent()
  if event == "monitor_touch" then
    drawListOverlay()
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
          displayExchangeModal()
        end
      end
    elseif currentDisplay == "modal" then
      if isWithinCoords(xPos, yPos, modalButtons.cancelCoords) then
        currentDisplay = "list"
        transactionQty = 0
        refresh()
      end
      if isWithinCoords(xPos, yPos, modalButtons.okCoords) then
        buy()
      end
      for i in pairs(modalButtons.plus) do
        if isWithinCoords(xPos, yPos, modalButtons.plus[i]) then
          updateQuantity(transactionQty + i)
        end
      end
      for i in pairs(modalButtons.minus) do
        if isWithinCoords(xPos, yPos, modalButtons.minus[i]) then
          updateQuantity(transactionQty - i)
        end
      end
    end
  end
end

rednet.broadcast("reload", reloadProtocol)
