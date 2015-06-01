--the thingspeak api to use
--dapi="YH4YN6VWTKLZN58H" --001
--sapi="39FCF7QAGRAV1LV9" --001

dapi="M8UM5QKG9S25PUCG" --002
sapi="V4FIQ8QKOJFGCEJ8" --002

--how often to run
local howoften=120000

--global variables used across files
startheap=0
pfails=0
tfails=0
tsuccess=true
cc=0
--temp2 = 0
--temperature = 0
--tempdiff = nil
--humidity = 0
--avms = 0
--timelist = {}
--successlist = {}
--clist = {}


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


