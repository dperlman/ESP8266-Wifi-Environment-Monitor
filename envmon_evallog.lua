
local requesttext = "GET /update?key="..dapi..
  "&field1="..tostring(avms)..
  "&field2="..tostring(temp2)..
  "&field3="..tostring(temperature)..
  "&field4="..tostring(humidity)..
  "&field5="..tostring(timelist[1])..
  "&field6="..tostring(timelist[2])..
  "&field7="..tostring(timelist[3])..
  "&field8="..tostring(tempdiff)..
  " HTTP/1.1\r\n".. 
  "Host: api.thingspeak.com\r\n"..
  "Accept: */*\r\n"..
  --"User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n"..
  "\r\n"


cc=cc+1
local conn=net.createConnection(net.TCP, 0) 

conn:on("connection", 
  function(c)
    c:send(requesttext)
  end)
conn:on("receive", 
  function(c, p)
    c:close()
    print(p:gsub('(.-)\n.-\n(.-)\n.*', '%1 %2 ...etc.', 1))
  end)
conn:on("disconnection", 
  function(c)
    --print("disconnection", node.heap())
    --avms=nil
    --temp2=nil
    --temperature=nil
    --humidity=nil
    --timelist=nil
    --successlist=nil
    --clist=nil
    --cfails=nil
  end)


print("DATA,"..tostring(avms)..","..tostring(timelist[1])..","..tostring(timelist[2])..","..tostring(timelist[3])..","..tostring(temp2)..","..tostring(temperature)..","..tostring(tempdiff)..","..tostring(humidity))

--conn:connect(80,'thingspeak.com') 
conn:connect(80,'184.106.153.149') 
