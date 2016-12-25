local MODULE = 'doorbell'
local log = require 'log'
local m = require 'mqtt-connect'
local ifttt = require 'ifttt'

doorbell = {}
doorbell.PIN_A = 5
doorbell.PIN_B = 6
doorbell.PIN_C = 7
doorbell.PIN_D = 8

doorbell.ring = function(button)
    log.log(4, MODULE, "pressed "..button)
    ifttt.trigger('press', button)
    m.client:publish(m.prefix .. "/door", '{"door":"' .. button .. '"}', 0, 0)
end

gpio.mode(doorbell.PIN_A, gpio.INT, gpio.PULLUP)
gpio.mode(doorbell.PIN_B, gpio.INT, gpio.PULLUP)
gpio.mode(doorbell.PIN_C, gpio.INT, gpio.PULLUP)
gpio.mode(doorbell.PIN_D, gpio.INT, gpio.PULLUP)

gpio.trig(doorbell.PIN_A, 'up', function() doorbell.ring(doorbell.PIN_A) end)
gpio.trig(doorbell.PIN_B, 'up', function() doorbell.ring(doorbell.PIN_B) end)
gpio.trig(doorbell.PIN_C, 'up', function() doorbell.ring(doorbell.PIN_C) end)
gpio.trig(doorbell.PIN_D, 'up', function() doorbell.ring(doorbell.PIN_D) end)

return doorbell
