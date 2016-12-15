local MODULE = 'wifi'
local log = require 'log'

local w = {}
w.TIMER = 1
w.ssid = config.wifi_ssid
w.password = config.wifi_password

w.connect = function(cb)
    log.info(MODULE, 'connecting to wifi...')
    if ready ~= nil then ready.not_ready() end
    wifi.setmode(wifi.STATION)
    wifi.sta.config(w.ssid, w.password)
    tmr.alarm(w.TIMER, 1000, tmr.ALARM_AUTO, function()
        if wifi.sta.getip() == nil then
            log.trace(MODULE, 'waiting for IP address...')
        else
            tmr.stop(w.TIMER)
            log.info(MODULE, 'wifi connection established')
            log.info(MODULE, 'IP address is ' .. wifi.sta.getip())
            if cb ~= nil then cb() end
            if ready ~= nil then ready.ready() end
        end
    end)
end

return w
