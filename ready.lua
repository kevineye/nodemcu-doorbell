ready = 1
local TIMER         = 2

gpio.mode(PIN_LED, gpio.OUTPUT)
tmr.alarm(TIMER, 3000, tmr.ALARM_AUTO, function()
    if (ready <= 0) then
        tmr.unregister(TIMER)
    else
        gpio.serout(PIN_LED, gpio.LOW, { 50000, 50000 }, 3, 1)
    end
end)

return ready
