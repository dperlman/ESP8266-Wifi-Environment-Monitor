temp2 = 0
temperature = 0
tempdiff = nil
humidity = 0
avms = 0


--print("temphum", node.heap())

--dht22 version
--print("pre-dht heap", node.heap())
local therm = require("dht_lib")
therm.read22(3) --gpio0
local thermtemp = therm.getTemperature()
--print("dht temp raw", thermtemp)
--local dhtT = therm.getTemperature() * 1000 --so it's on same scale as the ds18b20
local dhtT = thermtemp * 1000 --so it's on same scale as the ds18b20
humidity = therm.getHumidity()
local hh = tostring(humidity)
--print("dht humid raw", humidity)
humidity = hh:sub(1,-2).."."..hh:sub(-1)
therm = nil
package.loaded["dht_lib"]=nil
_G["dht_lib"]=nil
--print("post-dht heap", node.heap())
collectgarbage()
--print("post-dht-gc heap", node.heap())


--ds18b20 version
--print("pre-ds heap", node.heap())
local therm = require("ds18b20INT")
therm.setup(3) --gpio0
local dsT
repeat
  dsT=therm.readNumber()
until dsT ~= 850000
--therm.readNumber()
--therm.readNumber()
--local dsT=therm.readNumber()
--if dsT == 850000 then
--  dsT = nil
--end
therm=nil
package.loaded["ds18b20INT"]=nil
_G["ds18b20INT"]=nil
--print("post-ds heap", node.heap())
collectgarbage()
--print("post-ds-gc heap", node.heap())

local tt
--calc diff
if dhtT and dsT then
  tempdiff = dsT - dhtT
  tt = '0'..tostring(tempdiff)
  tempdiff = tt:sub(1,-5).."."..tt:sub(-4)
else
  tempdiff = nil
end

--clean up the numbers 
tt = tostring(dhtT)
temperature = tt:sub(1,-5).."."..tt:sub(-4)
tt = tostring(dsT)
temp2 = tt:sub(1,-5).."."..tt:sub(-4)

--print("package.loaded done", node.heap())
