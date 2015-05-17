wifi.setmode(wifi.STATIONAP)
print(wifi.sta.getip())
print("Stop timer alarm 0 and 1 to interrupt")

--keep track of count of failed connections
pfails=0
tfails=0

tmr.alarm(1, 15000, 0,
  function()
    dofile("envmon_reboot.lc")
  end)

tmr.alarm(0, 60000, 1, 
  function() 
    dofile("envmon.lc") 
  end)


