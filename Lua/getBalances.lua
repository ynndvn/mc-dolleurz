dofile("./commons.lua")

function display (input, monitor)
  local lines = split(input, "|")
  local nickLength = 0
  local balanceLength = 0
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
    local infos = split(l, " : ")
    local sizedNick = string.sub(infos[1] .. string.rep(" ", nickLength), 1, nickLength)
    local sizedBalance = string.sub(infos[2] .. string.rep(" ", balanceLength), 1, balanceLength)
    prompt(monitor, sizedNick .. " : " .. sizedBalance)
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