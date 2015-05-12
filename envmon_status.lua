local vv = tostring(adc.readvdd33(0))

local requesttext = "GET /update?key=39FCF7QAGRAV1LV9"..
  "&field2="..tostring(startheap)..
  "&field6="..vv:sub(1,-4).."."..vv:sub(-3)..
  " HTTP/1.1\r\n".. 
  "Host: api.thingspeak.com\r\n"..
  "Accept: */*\r\n"..
  --"User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n"..
  "\r\n"

  

local stconn=net.createConnection(net.TCP, 0) 

stconn:on("connection", 
  function(c)
    c:send(requesttext)
    print(requesttext)
  end)
stconn:on("receive", 
  function(c, p)
    c:close()
    print(p)
  end)
stconn:on("disconnection", 
  function(c)
    print("disconnection", node.heap())
    --print("restarting now!")
    --node.restart()
  end)


print("sending status")

--stconn:connect(80,'thingspeak.com') 
stconn:connect(80,'184.106.153.149') 
