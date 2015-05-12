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


timelist = {0, 0, 0}
successlist = {false, false, false}

temperature = 0
humidity = 0
avms = 0
datetime = ""


local function temphum()
  print("temphum", node.heap())
  therm = require("ds18b20INT")
  therm.setup(3) --gpio0
  therm.read()
  therm.read()
  temperature=therm.read()
  humidity=0
  therm=nil
  package.loaded["ds18b20INT"]=nil
  _G["ds18b20INT"]=nil
  print("package.loaded done", node.heap())
end



local function startping(i, host)
  --print("startping", i, host, node.heap())
  local conn = net.createConnection(net.TCP, 0)
  local requesttext = string.gsub(requesttemplate, "#HOST#", host)
  local connectTime = tmr.now()
  conn:on("connection",  
    function(c) 
      c:send(requesttext) 
    end)
  conn:on("receive", 
    function(c, payload) 
      timelist[i] = (tmr.now() - connectTime)
      successlist[i]=true
      print(i, host, timelist[i])
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
    for i,v in ipairs(timelist) do
      avms = avms + v
    end
    avms = avms/ #timelist
    print("logging data ms:", avms, "temp:", temperature, "heap:", node.heap())
    -- do next file here
    dofile("envmon_evallog.lc")
  end)

tmr.alarm(3, 7000, 0, 
  function() 
    print("logging status", node.heap())
    -- do next file here
    dofile("envmon_status.lc")
  end)
