local MODULE = 'doorbell'
local log = require 'log'
local m = require 'mqtt-connect'
local ifttt = require 'ifttt'

local doorbell = {}
doorbell.PIN_A = 5
doorbell.PIN_B = 6
doorbell.PIN_C = 7
doorbell.PIN_D = 8
doorbell.PIN_C1 = 1
doorbell.PIN_C2 = 2

doorbell.names = {}
doorbell.names[doorbell.PIN_A] = "mud room"
doorbell.names[doorbell.PIN_B] = "side porch"
doorbell.names[doorbell.PIN_C] = "back porch"
doorbell.names[doorbell.PIN_D] = "front porch"

doorbell.chimes = {}
doorbell.chimes[doorbell.PIN_A] = doorbell.PIN_C1
doorbell.chimes[doorbell.PIN_B] = doorbell.PIN_C1
doorbell.chimes[doorbell.PIN_C] = doorbell.PIN_C1
doorbell.chimes[doorbell.PIN_D] = doorbell.PIN_C2

doorbell.ring = function(button)
    local name = doorbell.names[button]
    log.log(4, MODULE, "pressed " .. button .. " (" .. name .. ")")
    doorbell.ding(doorbell.chimes[button])
    ifttt.trigger('doorbell', button, name)
    m.client:publish(m.prefix .. "/door", '{"door_id":"' .. button .. '","door_name":"' .. name .. '"}', 0, 0)
end

doorbell.ding = function(pin)
    gpio.serout(pin, gpio.HIGH, { 750000, 50000 }, 1, 1)
end

gpio.mode(doorbell.PIN_C1, gpio.OUTPUT)
gpio.mode(doorbell.PIN_C2, gpio.OUTPUT)
gpio.write(doorbell.PIN_C1, gpio.LOW)
gpio.write(doorbell.PIN_C2, gpio.LOW)

gpio.mode(doorbell.PIN_A, gpio.INT)
gpio.mode(doorbell.PIN_B, gpio.INT)
gpio.mode(doorbell.PIN_C, gpio.INT)
gpio.mode(doorbell.PIN_D, gpio.INT)

gpio.trig(doorbell.PIN_A, 'up', function() doorbell.ring(doorbell.PIN_A) end)
gpio.trig(doorbell.PIN_B, 'up', function() doorbell.ring(doorbell.PIN_B) end)
gpio.trig(doorbell.PIN_C, 'up', function() doorbell.ring(doorbell.PIN_C) end)
gpio.trig(doorbell.PIN_D, 'up', function() doorbell.ring(doorbell.PIN_D) end)

m.onMessage(function(_, t)
    log.log(7, MODULE, "git " .. t .. " via mqtt")
    if (t == m.prefix .. "/ding") then
        doorbell.ding(doorbell.PIN_C2);
    end
    if (t == m.prefix .. "/dingdong") then
        doorbell.ding(doorbell.PIN_C1);
    end
end)

m.onConnect(function()
    m.client:subscribe(m.prefix .. "/ding", 0)
    m.client:subscribe(m.prefix .. "/dingdong", 0)
end)

return doorbell
