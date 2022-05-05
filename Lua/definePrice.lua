dofile("./commons.lua")
rednet.open("front")

inventoryManager = getPeripheral("inventoryManager")

function definePrice()
  print("Quel prix ?")
  local price = io.read()
  local item = inventoryManager.getItemInHand()
  if item == nil then
    print("T'as rien dans la main bg")
  end
  post("/offers/" .. item.name, '{"price": ' .. price .. '}')
  rednet.broadcast("reload", "reload_buy")
  print(item.name .. " : " .. price .. " F/u")
end


while true do
  definePrice()
end