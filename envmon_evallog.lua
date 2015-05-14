local requesttext = "GET /update?key=YH4YN6VWTKLZN58H"..
  "&field1="..tostring(avms/1000)..
  "&field2="..tostring(temp2)..
  "&field3="..tostring(temperature)..
  "&field4="..tostring(humidity)..
  "&field5="..tostring(timelist[1]/1000)..
  "&field6="..tostring(timelist[2]/1000)..
  "&field7="..tostring(timelist[3]/1000)..
  " HTTP/1.1\r\n".. 
  "Host: api.thingspeak.com\r\n"..
  "Accept: */*\r\n"..
  --"User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n"..
  "\r\n"


local conn=net.createConnection(net.TCP, 0) 

conn:on("connection", 
  function(c)
    c:send(requesttext)
  end)
conn:on("receive", 
  function(c, p)
    c:close()
  end)
conn:on("disconnection", 
  function(c)
    print("disconnection", node.heap())
    avms=nil
    temp2=nil
    temperature=nil
    humidity=nil
    timelist=nil
    successlist=nil
  end)


print("sending data")

--conn:connect(80,'thingspeak.com') 
conn:connect(80,'184.106.153.149') 
