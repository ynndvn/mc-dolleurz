function post (route, body) 
  local headers = nil
  if #body > 0 then
    headers = { ["Content-Type"] = "application/json" }
  end
  local result = http.post("https://mc.ydav.in" .. route, body, headers)
  return result
end

function get (route) 
  local result = http.get("https://mc.ydav.in" .. route)
  return result
end

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

local chatBox = peripheral.wrap("chatBox_1")
while true do
  event, from, message = os.pullEvent("chat")
  splitted = split(message, " ")
  if #splitted == 3 and starts(message, "pay ") then
    to = splitted[2]
    amount = splitted[3]
    result = post("/transactions", '{"from": "' .. from .. '", "to": "' .. to .. '", "amount": "' .. amount .. '" }')
    if result == nil then
      chatBox.sendMessage("Erreur lors du transfert ! T'as assez de thunes pelo ?", "BANQUE")
    else
      chatBox.sendMessage(from .. " a transféré " .. amount .. " Floydies sur le compte de " .. to, "BANQUE")
    end
  elseif message == "balance" then
    balance = get("/players/" .. from .. "/balance")
    chatBox.sendMessage("Balance de " .. from .. " : " .. balance .. " Floydies", "BANQUE")
  end
end