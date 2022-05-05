-- PERIPHERALS

function getPeripheral (name) 
  local result = peripheral.find(name) or error("Périphérique " .. name .. " introuvable.", 0)
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

function trim(s)
   return s:match'^%s*(.*%S)' or ''
end

function parseNumber(n)
  if n > 1000 then
    local thousands = math.floor(n / 1000)
    local rest = string.sub(("" .. (n % 1000)), 1, 2)
    return thousands .. "." .. rest .. "k"
  end
  return n
end

function centerText(str, size)
  if #str >= size then
    return string.sub(str, 1, size)
  end
  local before = string.rep(" ", math.ceil((size - #str) / 2))
  local after = string.rep(" ", math.floor((size - #str) / 2))
  return before .. str .. after
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

function prompt (monit, text, center)
    local x, y = monit.getCursorPos()
    local width, height = monit.getSize()
    
    local lines = math.ceil(#text / width)
    if y + lines > height then
        monit.clear()
    end
    for i = 1, lines, 1 do
        local substr = string.sub(text, width * (i - 1) + 1, width * i)
        if center == true then
          monit.setCursorPos(math.ceil((width - #text) / 2), y)
        end
        monit.write(substr)
        monit.setCursorPos(1, y % height + i)
    end
end

function cl(monitor)
    monitor.clear()
    monitor.setCursorPos(1,1)
end

-- MISC

function sortObject(obj)
  local tkeys = {}
  local result = {}
  -- populate the table that holds the keys
  for k in pairs(obj) do table.insert(tkeys, k) end
  -- sort the keys
  table.sort(tkeys)
  -- use the keys to retrieve the values in the sorted order
  for _, k in ipairs(tkeys) do result[k] = obj[k] end
  return result
end

function initButtonCoords()
  return { left = { 0, 0 }, right = { 0, 0 } }
end

reloadProtocol = "reloadDisplay"
