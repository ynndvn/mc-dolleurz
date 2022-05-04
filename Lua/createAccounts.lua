dofile("./commons.lua")

local chatBox = getPeripheral("chatBox")
local monitor = getPeripheral("monitor")
local detector = getPeripheral("playerDetector")
rednet.open("front")

cl(monitor)
prompt(monitor, "Fais un clic droit sur la    tête pour créer ton compte   bancaire !")

while true do
  event, username = os.pullEvent("playerClick")
  result = post("/players", '{"nickname": "' .. username .. '"}')
  if result ~= nil then
    chatBox.sendMessage("Le compte bancaire de " .. username .. " a bien été créé.", "BANQUE")
    rednet.broadcast("reload", reloadProtocol)
  end
end