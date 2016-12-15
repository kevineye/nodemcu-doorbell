local MODULE = 'init'

init = {}
init.STARTUP_DELAY  = 3000
init.TIMER = 0

local log = require 'log'
require 'constants'
local config = require 'config'
local ready = require 'ready'
local w = require 'wifi-connect'

w.connect(function()
    log.trace(MODULE, 'waiting to initialize...')
    tmr.alarm(init.TIMER, init.STARTUP_DELAY, tmr.ALARM_SINGLE, function()
        if file.open("init.lua") == nil then
            log.fatal(MODULE, 'aborting startup; init.lua deleted or renamed')
        else
            file.close("init.lua")
            for i = 1, #MAIN_MODULES do
                log.info(MODULE, 'loading ' .. MAIN_MODULES[i])
                require(MAIN_MODULES[i])
            end
            ready.ready()
        end
    end)
end)
