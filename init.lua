wifi.setmode(wifi.STATIONAP)
print(wifi.sta.getip())
print("Stop timer alarm 0 and 1 to interrupt")



tmr.alarm(0, 15000, 0,
  function()
    dofile("envmon_reboot.lc")
  end)

tmr.alarm(1, 60000, 1, 
  function() 
    dofile("envmon.lc") 
  end)


