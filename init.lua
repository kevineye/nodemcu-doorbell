local MODULE = 'init'

init = {}
init.STARTUP_DELAY  = 3000
init.TIMER_STARTUP  = 0
init.TIMER_WIFI     = 1

local log = require 'log'
require 'constants'
local config = require 'config'
local ready = require 'ready'

log.info(MODULE, 'connecting to wifi...')
wifi.setmode(wifi.STATION)
wifi.sta.config(config.wifi_ssid, config.wifi_password)
tmr.alarm(init.TIMER_WIFI, 1000, tmr.ALARM_AUTO, function()
    if wifi.sta.getip() == nil then
        log.trace(MODULE, 'waiting for IP address...')
    else
        tmr.stop(init.TIMER_WIFI)
        log.info(MODULE, 'wifi connection established')
        log.info(MODULE, 'IP address is ' .. wifi.sta.getip())
        log.trace(MODULE, 'waiting to initialize...')
        tmr.alarm(init.TIMER_STARTUP, init.STARTUP_DELAY, tmr.ALARM_SINGLE, function()
            if file.open("init.lua") == nil then
                log.fatal(MODULE, 'aborting startup; init.lua deleted or renamed')
            else
                file.close("init.lua")
                for i = 1, #MAIN_MODULES do
                    log.info(MODULE, 'loading ' .. MAIN_MODULES[i])
                    require(MAIN_MODULES[i])
                end
            end
        end)
    end
end)
