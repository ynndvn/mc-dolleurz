function post (route, body) 
  local headers = nil
  if #body > 0 then
    headers = { ["Content-Type"] = "application/json" }
  end
  local result = http.post("https://mc.ydav.in" .. route, body, headers)
  return result
end

-- local chatBox = peripheral.wrap("chatBox_0")
 
-- chatBox.sendMessage("Oh oui le zizi", "BANQUE")
 
local detector = peripheral.wrap("playerDetector_1")
while true do
  event, username = os.pullEvent("playerClick")
  post("/players", '{"nickname": "' .. username .. '"}')
end