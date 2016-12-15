local MODULE = 'mqtt'
local log = require 'log'

local m = {}
m.TIMER             = 3
m.STATUS_INTERVAL   = 5 * 60000
m.clientid          = config.get('mqtt_clientid')
m.user              = config.get('mqtt_user')
m.password          = config.get('mqtt_password')
m.prefix            = config.get('mqtt_prefix')
m.host              = config.get('mqtt_host')
m.port              = config.get('mqtt_port')

if ready ~= nil then ready.not_ready() end

m.client = mqtt.Client(m.clientid, 60, m.user, m.password)
m.client:lwt(m.prefix .. "/status", '{"status":"offline"}', 0, 1)

local function sendstatus()
    local msg = '{"status":"online","ip":"' .. wifi.sta.getip() .. '","heap":' .. node.heap() .. ',"minutesOnline":' .. math.floor(tmr.now() / 60000000) .. '}'
    log.debug(MODULE, "sending " .. m.prefix .. "/status " .. msg)
    m.client:publish(m.prefix .. "/status", msg, 0, 1)
end

m.client:on("connect", function()
    log.info(MODULE, 'connected to ' .. m.host .. ':' .. m.port)
    if ready ~= nil then ready.ready() end
    m.client:subscribe(m.prefix .. "/ping", 0)
    m.client:subscribe(m.prefix .. "/config", 0)
    sendstatus()
end)

m.client:on("offline", function()
    log.fatal(MODULE, 'disconnected')
end)

m.client:on("message", function(client, t, pl)
    if pl == nil then pl = "" end
    log.debug(MODULE, "received " .. t .. ": " .. pl)
    if (t == m.prefix .. "/ping") then
        sendstatus()
    elseif config ~= nil and t == m.prefix .. "/config" then
        if (pl == "ping") then
            local msg = cjson.encode(config.get())
            log.debug(MODULE, "sending " .. m.prefix .. "/config/json: " .. msg)
            m.client:publish(m.prefix .. "/config/json", msg, 0, 0)
        elseif (pl == "restart") then
            node.restart()
        else
            config.set_string(pl)
        end
    end
end)

tmr.alarm(m.TIMER, m.STATUS_INTERVAL, tmr.ALARM_AUTO, sendstatus)

log.trace(MODULE, 'connecting to ' .. m.host .. ':' .. m.port)
m.client:connect(m.host, m.port, 0, 1)

return m
