dofile("./commons.lua")
rednet.open("front")

inventoryManager = getPeripheral("inventoryManager")
detector = getPeripheral("playerDetector")
user = ""

function getClosestPlayer() 
  local players = detector.getPlayersInRange(2)
  if #players == 0 then
    user = ""
  else
    user = players[1]
  end
end

function definePrice()
  print("Quel prix ?")
  local price = io.read()
  local item = inventoryManager.getItemInHand()
  if item == nil then
    print("T'as rien dans la main bg")
    return
  end
  getClosestPlayer()
  print(user)
  if user ~= "Degarni" then
    print("Inconnu au bataillon")
    return
  end
  post("/offers/" .. item.name, '{"price": ' .. price .. '}')
  rednet.broadcast("reload", "reload_buy")
  print(item.name .. " : " .. price .. " F/u")
end


while true do
  definePrice()
end