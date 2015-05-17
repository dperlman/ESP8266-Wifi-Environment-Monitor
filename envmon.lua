collectgarbage()
startheap=node.heap()
print("starting envmon, heap", startheap)


local requesttemplate = "HEAD / HTTP/1.1\r\n".. 
  "Host: #HOST#\r\n"..
  "Accept: */*\r\n"..
  "User-Agent: Mozilla/4.0 (compatible; esp8266 Lua;)"..
  "\r\n\r\n"


local hostlist = 
  {"google.com",
  "yahoo.com",
  "wisc.edu"}


timelist = {}
successlist = {false, false, false}
clist = {}

temp2 = 0
temperature = 0
humidity = 0
avms = 0
datetime = ""


local function temphum()
  --print("temphum", node.heap())
  
  --dht22 version
  therm = require("dht_lib")
  therm.read22(3) --gpio0
  temperature = therm.getTemperature()
  humidity = therm.getHumidity()
  local tt = tostring(temperature)
  temperature = tt:sub(1,-2).."."..tt:sub(-1)
  tt = tostring(humidity)
  humidity = tt:sub(1,-2).."."..tt:sub(-1)
  DHT = nil
  package.loaded["dht_lib"]=nil
  _G["dht_lib"]=nil
  
  --ds18b20 version
  therm = require("ds18b20INT")
  therm.setup(3) --gpio0
  therm.read()
  therm.read()
  temp2=therm.read()
  therm=nil
  package.loaded["ds18b20INT"]=nil
  _G["ds18b20INT"]=nil
  

  --print("package.loaded done", node.heap())
end



local function startping(i, host)
  --print("startping", i, host, node.heap())
  local conn = net.createConnection(net.TCP, 0)
  local connectTime
  clist[i]=conn
  local requesttext = string.gsub(requesttemplate, "#HOST#", host)
  conn:on("connection",  
    function(c) 
      c:send(requesttext) 
    end)
  conn:on("receive", 
    function(c, payload) 
      timelist[i] = (tmr.now() - connectTime)
      successlist[i]=true
      --print(i, host, timelist[i])
      --print(payload)
      c:close()
    end)
  conn:on("disconnection", 
    function(c)
      if not successlist[i] then
        timelist[i] = (tmr.now() - connectTime)
        print("timeout", timelist[i])
      end
      print(successlist[i], timelist[i], host)
    end)
  
  --start the thing
  connectTime = tmr.now()
  conn:connect(80,host)
  print("started", i, host, node.heap())
end




temphum()

for i,host in pairs(hostlist) do
  startping(i, host)
end
--set up a timer to compile the results after this is hopefully for sure all done
tmr.alarm(2, 5000, 0, 
  function() 
    local avn=0
    for i,c in ipairs(clist) do
      --calculate the average time over the ones that worked and count the ones that didn't
      if successlist[i] then
        avms = avms + timelist[i]
        avn=avn+1
      else
        pfails=pfails+1
        timelist[i]="fail"
      end
      --clean up if the connection still exists
      if c then
        c:close()
        c=nil
      end
        
    end
    avms = avms/avn
    -- log the data
    dofile("envmon_evallog.lc")
  end)

tmr.alarm(3, 7000, 0, 
  function() 
    --print("logging status", node.heap())
    -- do next file here
    dofile("envmon_status.lc")
  end)
