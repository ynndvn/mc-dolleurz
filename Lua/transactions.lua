dofile("./commons.lua")

rednet.open("top")

local chatBox = getPeripheral("chatBox")

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
      rednet.broadcast("reload", reloadProtocol)
    end
  elseif message == "balance" then
    local balance = get("/players/" .. from .. "/balance")
    if balance ~= nil then
      chatBox.sendMessage("Balance de " .. from .. " : " .. balance.readAll() .. " Floydies", "BANQUE")
    end
  end
end