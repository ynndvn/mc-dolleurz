dofile("./commons.lua")
rednet.open("left")

monitor = getPeripheral("monitor")

cl(monitor)
prompt(monitor, " ")
prompt(monitor, "Recharger les stocks", true)
prompt(monitor, " ")
prompt(monitor, " ")
prompt(monitor, "Recharger les ventes", true)
prompt(monitor, " ")
prompt(monitor, " ")
prompt(monitor, "Recharger les balances", true)
prompt(monitor, " ")
prompt(monitor, " ")
prompt(monitor, "Ça va toi ?", true)

function fireEvent(text)
  rednet.broadcast("r", text)
end

while true do
  local event, side, xPos, yPos = os.pullEvent()
  if event == "monitor_touch" then
    if yPos <= 3 then
      fireEvent("reload_buy")
    elseif yPos <= 6 then
      fireEvent("reload_sell")
    elseif yPos <= 9 then
      fireEvent(reloadProtocol)
    else
      print("Bah écoute à l'ancienne frr")
    end
  end
end