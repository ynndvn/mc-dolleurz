dofile("./commons.lua")

function display (input, monitor)
  local lines = split(input, "|")
  local nickLength = 0
  local balanceLength = 0
  local width, height = monitor.getSize()

  monitor.setCursorPos(1, math.ceil((height - #lines) / 2))
  for i,l in pairs(lines) do
    local infos = split(l, ":")
    if #infos[1] > nickLength then
      nickLength = #infos[1]
    end 
    if #infos[2] > balanceLength then
      balanceLength = #infos[2]
    end 
  end

  for i,l in pairs(lines) do
    local infos = split(l, ":")
    local sizedNick = string.sub(infos[1] .. string.rep(" ", nickLength), 1, nickLength)
    local spacesToAdd = balanceLength - #infos[2]
    local sizedBalance = string.rep(" ", spacesToAdd) .. infos[2]
    prompt(monitor, sizedNick .. " : " .. sizedBalance, true)
  end
end

local monitor = getPeripheral("monitor")

function reloadDisplay()
  cl(monitor)
  prompt(monitor, "Balances", true)
  monitor.setTextScale(1.5)
  local result = get("/players")

  if result == nil then
    prompt(monitor, "Ça marche pas oh")
  else
    display(result.readAll(), monitor)
  end
end

reloadDisplay()

rednet.open("left")
while true do
  local senderId, message, protocol = rednet.receive(reloadProtocol)
  reloadDisplay()
end