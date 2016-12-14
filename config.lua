local MODULE = 'config'
local log = require 'log'

config = {}
config.filename = 'config.json'

function config.read_json()
    log.trace(MODULE, 'loading config from ' .. config.filename)
    file.open(config.filename, "r")
    config = cjson.decode(file.read())
    file.close()
end

config.read_json()

return config
