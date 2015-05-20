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
tempdiff = 0
humidity = 0
avms = 0
datetime = ""




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
