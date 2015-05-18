wifi.setmode(wifi.STATIONAP)
print(wifi.sta.getip())
print("Stop timer alarm 0 and 1 to interrupt")

--keep track of count of failed connections
pfails=0
tfails=0
tsuccess=true

--the api to use
--local dapi="YH4YN6VWTKLZN58H" --001
--local sapi="39FCF7QAGRAV1LV9" --001

local dapi="M8UM5QKG9S25PUCG" --002
local sapi="V4FIQ8QKOJFGCEJ8" --002



tmr.alarm(1, 15000, 0,
  function()
    dofile("envmon_reboot.lc")
  end)

tmr.alarm(0, 60000, 1, 
  function() 
    dofile("envmon.lc") 
  end)


