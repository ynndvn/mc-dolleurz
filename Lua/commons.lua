-- PERIPHERALS

function getPeripheral (name) 
  local result = peripheral.find(name)
  if result == nil then
    print("Périphérique " .. name .. " introuvable.")
    os.exit()
  end
  return result
end

-- STRING

function starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

function split(str, sep)
   local result = {}
   local regex = ("([^%s]+)"):format(sep)
   for each in str:gmatch(regex) do
      table.insert(result, each)
   end
   return result
end

-- HTTP

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

-- MONITORS

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

function cl(monitor)
    monitor.clear()
    monitor.setCursorPos(1,1)
end