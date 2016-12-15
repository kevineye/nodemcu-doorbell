local MODULE = 'ready'
local log = require 'log'

ready = {}
ready.is_ready      = false
ready.counter       = 1
ready.TIMER         = 2

gpio.mode(PIN_LED, gpio.OUTPUT)
tmr.alarm(ready.TIMER, 1000, tmr.ALARM_AUTO, function()
    if (ready.is_ready) then
        tmr.unregister(ready.TIMER)
    else
        gpio.serout(PIN_LED, gpio.LOW, { 50000, 50000 }, 3, 1)
    end
end)

function ready.not_ready()
    ready.counter = ready.counter + 1
    log.trace(MODULE, 'not_ready; ready counter is now '.. ready.counter)
end

function ready.ready()
    if ready.counter > 0 then
        ready.counter = ready.counter - 1
    end
    log.trace(MODULE, 'ready; ready counter is now '.. ready.counter)
    ready.is_ready = ready.counter == 0
end

return ready
