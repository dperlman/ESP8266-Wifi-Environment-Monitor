if tsuccess then
  tfails = 0
else
  tfails = tfails + 1
end

local uptime=tmr.time()

local vv = tostring(adc.readvdd33(0))
local v = vv:sub(1,-4).."."..vv:sub(-3)
local requesttext = "GET /update?key="..sapi..
  "&field2="..tostring(startheap)..
  "&field4="..tostring(pfails)..
  "&field5="..tostring(cc)..
  "&field6="..v..
  "&field7="..tostring(tfails)..
  "&field8="..tostring(uptime)..
  " HTTP/1.1\r\n".. 
  "Host: api.thingspeak.com\r\n"..
  "Accept: */*\r\n"..
  --"User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n"..
  "\r\n"

  

cc=cc+1
local stconn=net.createConnection(net.TCP, 0) 

stconn:on("connection", 
  function(c)
    c:send(requesttext)
    --print(requesttext)
  end)
stconn:on("receive", 
  function(c, p)
    c:close()
    pfails=0
    tsuccess=true
    print(p:gsub('(.-)\n.-\n(.-)\n.*', '%1 %2 ...etc.', 1))
    -- !!!!! could check here that it is actually the right response
  end)
stconn:on("disconnection", 
  function(c)
    --print("disconnection", node.heap())
    --print("restarting now!")
    --node.restart()
  end)


print("STAT,"..tostring(pfails)..","..tostring(tfails)..","..tostring(uptime)..","..tostring(v)..","..tostring(startheap)..","..tostring(cc)..","..tostring(node.heap()))

tsuccess=false
--stconn:connect(80,'thingspeak.com') 
stconn:connect(80,'184.106.153.149') 
