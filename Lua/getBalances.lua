function cl(monitor)
    monitor.clear()
    monitor.setCursorPos(1,1)
end
 
function prompt (monit, text)
    local x, y = monit.getCursorPos()
    local width, height = monit.getSize()
    
    local lines = math.ceil(#text / width)
    if y + lines > height then
        monit.clear()
    end
    for i = 1, lines, 1 do
        local substr = string.sub(text, width * (i - 1) + 1, width * i)
        monit.write(substr)
        monit.setCursorPos(1, y % height + i)
    end
end

function get (route) 
  local result = http.get("https://mc.ydav.in" .. route)
  return result
end

function post (route, body) 
  local headers = nil
  if #body > 0 then
    headers = { ["Content-Type"] = "application/json" }
  end
  local result = http.post("https://mc.ydav.in" .. route, body, headers)
  return result
end

local monitor = peripheral.wrap("monitor_0")
cl(monitor)

local result = get("/players")

if result == nil then
  prompt(monitor, "Ça marche pas oh")
else
  for i,v in itables(result.readAll()) do 
    prompt(monitor, v.nickname .. " : " .. v.balance .. " Floydies")
  end
end