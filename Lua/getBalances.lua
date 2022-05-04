dofile("./commons.lua")

function display (input, monitor)
  local lines = split(input, "|")
  for i,l in pairs(lines) do
    print("test")
    prompt(monitor, l)
  end
end

local monitor = getPeripheral("monitor")
cl(monitor)
monitor.setTextScale(2)

local result = get("/players")

if result == nil then
  prompt(monitor, "Ça marche pas oh")
else
  display(result.readAll(), monitor)
end