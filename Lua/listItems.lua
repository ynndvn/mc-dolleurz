dofile("./commons.lua")
rednet.open("left")

local bridge = getPeripheral("meBridge")
local monitor = getPeripheral("monitor")

function displayList ()

end


function getOffers ()
  local result = get("/offers")
  result = result.readAll()

end

function getItems ()

end

rednet.broadcast("reload", reloadProtocol)
