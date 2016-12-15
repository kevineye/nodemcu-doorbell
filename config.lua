local MODULE = 'config'
local log = require 'log'

config = {}
config.filename = 'config.json'

if ready ~= nil then ready.not_ready() end

function config.read_json()
    log.trace(MODULE, 'loading config from ' .. config.filename)
    file.open(config.filename, "r")
    config = cjson.decode(file.read())
    file.close()
    if ready ~= nil then ready.ready() end
end

config.read_json()

return config
