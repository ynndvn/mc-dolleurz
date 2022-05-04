dofile("./commons.lua")
rednet.open("left")

local bridge = getPeripheral("meBridge")
local monitor = getPeripheral("monitor")

function displayList (items)
  local width, height = monitor.getSize()

  for i,item in pairs(items) do
    local price = ""
    if item.price ~= nil then
      price = " " .. item.price .. " F/u"
    end
    prompt(monitor, item.displayName .. " : " .. item.amount .. " en stock." .. price, true)
  end
end


function getOffers ()
  local result = get("/offers")
  local lines = textutils.unserializeJSON(result.readAll())
  
  local stocks = bridge.listItems()
  print(textutils.serializeJSON(lines))

  for i,s in pairs(stocks) do
    for j,l in pairs(lines) do
      local splitted = split(l, "^")
      print(splitted[1])
      if splitted[1] == s.name then
        s.price = splitted[2]
      end
    end
  end
  return stocks
end

function refresh ()
  local offers = getOffers()
  cl(monitor)
  prompt(monitor, "Stocks", true)
  monitor.setTextScale(1)
  displayList(offers)
end

refresh()

rednet.broadcast("reload", reloadProtocol)
