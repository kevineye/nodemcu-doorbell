PIN_LED         = 4

local log = require 'log'
log.level = 7

require 'config'
require 'ready'

local app = {}

function app.run()
    require 'telnet'
    require 'localtime'
    require 'mqtt-connect'
    require 'sensors'
    ready = ready - 1
end

return app
