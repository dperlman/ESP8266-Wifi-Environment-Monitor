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
tempdiff = nil
humidity = 0
avms = 0
datetime = ""


local function temphum()
  --print("temphum", node.heap())
  
  --dht22 version
  print("pre-dht heap", node.heap())
  therm = require("dht_lib")
  therm.read22(3) --gpio0
  local dhtT = therm.getTemperature() * 1000 --so it's on same scale as the ds18b20
  humidity = therm.getHumidity()
  local hh = tostring(humidity)
  humidity = hh:sub(1,-2).."."..hh:sub(-1)
  DHT = nil
  package.loaded["dht_lib"]=nil
  _G["dht_lib"]=nil
  print("post-dht heap", node.heap())
  collectgarbage()
  print("post-dht-gc heap", node.heap())
  
  
  --ds18b20 version
  print("pre-ds heap", node.heap())
  therm = require("ds18b20INT")
  therm.setup(3) --gpio0
  therm.readNumber()
  therm.readNumber()
  local dsT=therm.readNumber()
  if dsT == 850000 then
    dsT = nil
  end
  therm=nil
  package.loaded["ds18b20INT"]=nil
  _G["ds18b20INT"]=nil
  print("post-ds heap", node.heap())
  collectgarbage()
  print("post-ds-gc heap", node.heap())
  
  local tt
  --calc diff
  if dhtT and dsT then
    tempdiff = dsT - dhtT
    tt = '0'..tostring(tempdiff)
    tempdiff = tt:sub(1,-5).."."..tt:sub(-4)
  end

  --clean up the numbers 
  tt = tostring(dhtT)
  temperature = tt:sub(1,-5).."."..tt:sub(-4)
  tt = tostring(dsT)
  temp2 = tt:sub(1,-5).."."..tt:sub(-4)
  
  --print("package.loaded done", node.heap())
end



local function startping(i, host)
  --print("startping", i, host, node.heap())
  cc=cc+1
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
    avms=0
    local avn=0
    for i,c in ipairs(clist) do
      --calculate the average time over the ones that worked and count the ones that didn't
      if successlist[i] then
        avms = avms + timelist[i]
        avn=avn+1
        timelist[i]=timelist[i]/1000
      else
        pfails=pfails+1
        timelist[i]="fail"
        print("fail", hostlist[i])
      end
      --clean up if the connection still exists
      if c then
        c:close()
        c=nil
      end
        
    end
    if avn > 0 then
      avms = avms/(1000*avn)
    else
      avms = nil
    end
    -- log the data
    dofile("envmon_evallog.lc")
  end)

tmr.alarm(3, 7000, 0, 
  function() 
    --print("logging status", node.heap())
    -- do next file here
    dofile("envmon_status.lc")
  end)
