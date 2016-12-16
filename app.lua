PIN_LED         = 4

local log = require 'log'
log.level = log.DEBUG

require 'config'
require 'ready'

local app = {}

function app.run()
    require 'telnet'
    require 'mqtt-connect'
    require 'sensors'
    ready.ready()
end

return app
