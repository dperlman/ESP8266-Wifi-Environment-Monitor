--the thingspeak api to use
--dapi="YH4YN6VWTKLZN58H" --001
--sapi="39FCF7QAGRAV1LV9" --001

dapi="M8UM5QKG9S25PUCG" --002
sapi="V4FIQ8QKOJFGCEJ8" --002

--how often to run
local howoften=30000

--global variables used across files
pfails=0
tfails=0
tsuccess=true

--setup wifi
wifi.setmode(wifi.STATIONAP)
print(wifi.sta.getip())
print("Stop timer alarm 0 and 1 to interrupt")


--start the timers
tmr.alarm(1, 15000, 0,
  function()
    dofile("envmon_reboot.lc")
  end)

tmr.alarm(0, howoften, 1, 
  function() 
    dofile("envmon.lc") 
  end)


