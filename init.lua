local MODULE = 'init'

init = {}
init.STARTUP_DELAY  = 3000
init.TIMER = 0

local app = require 'app'
local log = require 'log'
local w = require 'wifi-connect'

w.connect(function()
    log.trace(MODULE, 'waiting to initialize...')
    tmr.alarm(init.TIMER, init.STARTUP_DELAY, tmr.ALARM_SINGLE, function()
        if file.open("init.lua") == nil then
            log.fatal(MODULE, 'aborting startup; init.lua deleted or renamed')
        else
            file.close("init.lua")
            app.run()
        end
    end)
end)
