--local apikey="39FCF7QAGRAV1LV9" --001
local apikey="V4FIQ8QKOJFGCEJ8" --002

local requesttext = "GET /update?key="..apikey..
  "&field1="..tostring(node.heap())..
  --"&field2=0"..
  " HTTP/1.1\r\n".. 
  "Host: api.thingspeak.com\r\n"..
  "Accept: */*\r\n"..
  --"User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n"..
  "\r\n"

local conn=net.createConnection(net.TCP, 0) 
conn:on("connection", 
  function(c)
    c:send(requesttext)
    --print(requesttext)
  end)
conn:on("receive", 
  function(c, p)
    c:close()
    print(p:match(".-\n.-\n.-\n"))
  end)

print("REBT,"..tostring(node.heap()))

--conn:connect(80,'thingspeak.com') 
conn:connect(80,'184.106.153.149') 
