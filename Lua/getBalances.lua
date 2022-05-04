dofile("./commons.lua")

function parse (input, monitor)
  prompt(monitor, input)
end

local monitor = getPeripheral("monitor")
cl(monitor)

local result = get("/players")

if result == nil then
  prompt(monitor, "Ça marche pas oh")
else
  prompt(monitor, result)
end