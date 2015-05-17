wifi.setmode(wifi.STATIONAP)
print(wifi.sta.getip())
print("Stop timer alarm 6 and 7 to interrupt")



tmr.alarm(6, 15000, 0,
  function()
    dofile("envmon_reboot.lc")
  end)

tmr.alarm(7, 60000, 1, 
  function() 
    dofile("envmon.lc") 
  end)


