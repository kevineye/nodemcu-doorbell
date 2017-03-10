PIN_LED         = 4

local log = require 'log'

require 'config'
require 'ready'

local app = {}

function app.run()
    require 'telnet'
    require 'mqtt-connect'
    require 'doorbell'
    ready = ready - 1
end

return app
