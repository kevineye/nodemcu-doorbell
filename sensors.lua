local MODULE = 'sensors'
local log = require 'log'
local m = require 'mqtt-connect'

local sensors = {}
sensors.SAMPLE_FREQ         = 10000  -- how often to sample sensors (ms)
sensors.REPORT_PERIOD       = 6      -- report every N samples
sensors.AVG_PERIOD          = 6      -- moving average of N samples
sensors.TIMER               = 4
sensors.PIN_SCL             = 1
sensors.PIN_SDA             = 2
sensors.zone                = config.get('zone') or 0

local countdown_to_report   = 0      -- number of samples until next report
local sample_count          = 0      -- how many sampless in the average
local avg_temp              = 0      -- current average temp

tmr.alarm(sensors.TIMER, sensors.SAMPLE_FREQ, tmr.ALARM_AUTO, function()
    if sample_count < sensors.AVG_PERIOD then
        sample_count = sample_count + 1
    end

    if sample_count == 1 then
        local res = bme280.init(sensors.PIN_SDA, sensors.PIN_SCL)
        log.info(MODULE, "initialized BME280: "..res)
    end

    local temp = bme280.temp()

    if temp == nil then
        log.warn(MODULE, "error reading temperature")
        return
    end

    temp = temp * 9 / 500 + 32; -- convert to fahrenheit and divide by 100
    log.trace(MODULE, 'read raw temperature '..temp)
    avg_temp = avg_temp + (temp - avg_temp) / sample_count

    if countdown_to_report == 0 then
        countdown_to_report = sensors.REPORT_PERIOD
        local msg = string.format('{"temperature":%0.1f,"zone":%d}', avg_temp, sensors.zone)
        log.debug(MODULE, 'logging ' .. msg)
        m.client:publish(m.prefix .. "/sensors", msg, 0, 0)
    end

    countdown_to_report = countdown_to_report - 1
end)

return sensors
