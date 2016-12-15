local MODULE = 'config'
local log = require 'log'

config = {}
config.data = {}
config.filename = file.exists('config.json') and 'config.json' or 'config.default.json'

if ready ~= nil then ready.not_ready() end

function config.read_json()
    log.debug(MODULE, 'loading config from ' .. config.filename)
    file.open(config.filename, "r")
    config.data = cjson.decode(file.read())
    file.close()
    if ready ~= nil then ready.ready() end
end

function config.set_string(s)
    local key, value = string.match(s, "([^=]+)=(.*)")
    if (key) then
        config.set(key, value)
    end
end

function config.set(key, value)
    config.data[key] = value
    config.save_json()
    log.warn(MODULE, "updated config " .. key .. " = " .. value)
end

function config.get(key)
    if key == nil then
        return config.data
    else
        return config.data[key]
    end
end

function config.save_json()
    file.remove(config.filename)
    file.open(config.filename, "w")
    file.write(cjson.encode(config.data))
    file.close()
end

config.read_json()

return config
