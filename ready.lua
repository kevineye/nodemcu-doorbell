local MODULE = 'ready'

local ready = {}
ready.is_ready      = false
ready.TIMER         = 2

gpio.mode(PIN_LED, gpio.OUTPUT)
tmr.alarm(ready.TIMER, 3000, tmr.ALARM_AUTO, function()
    if (ready.is_ready) then
        tmr.unregister(ready.TIMER)
    else
        gpio.serout(PIN_LED, gpio.LOW, { 50000, 50000 }, 3, 1)
    end
end)

function ready.ready()
    ready.is_ready = true
end

return ready
