local MODULE = 'sensors'
local log = require 'log'
local m = require 'mqtt-connect'

local sensors = {}
sensors.SAMPLE_FREQ         = 10000  -- how often to sample sensors (ms)
sensors.REPORT_PERIOD       = 6      -- report every N samples
sensors.AVG_PERIOD          = 6      -- moving average of N samples

sensors.TIMER               = 4

sensors.BME280_PIN_SCL      = 1
sensors.BME280_PIN_SDA      = 2
sensors.DHT_PIN             = nil
sensors.LIGHT_PIN           = nil

sensors.zone                = config.get('zone')

local countdown_to_report   = 0      -- number of samples until next report
local sample_count          = 0      -- how many sampless in the average
local avg_temp              = 0      -- current average temp
local avg_humi              = 0      -- current average humidity
local avg_light             = 0      -- current average light level

tmr.alarm(sensors.TIMER, sensors.SAMPLE_FREQ, tmr.ALARM_AUTO, function()
    if sample_count < sensors.AVG_PERIOD then
        sample_count = sample_count + 1
    end

    if sample_count == 1 then
        if bme280 ~= nil and sensors.BME280_PIN_SCL and sensors.BME280_PIN_SDA then
            local res = bme280.init(sensors.BME280_PIN_SDA, sensors.BME280_PIN_SCL)
            log.info(MODULE, "initialized BME280 sensor: "..res)
        end
        if dht ~= nil and sensors.DHT_PIN then
            log.info(MODULE, "using DHT sensor")
        end
        if adc ~= nil and sensors.LIGHT_PIN then
            log.info(MODULE, "using light sensor")
        end
    end

    local status
    local temp = 0
    local humi = 0
    local light = 0

    if bme280 ~= nil and sensors.BME280_PIN_SCL and sensors.BME280_PIN_SDA then
        temp = bme280.temp()
        if temp ~= nil then
            temp = temp * 9 / 500 + 32;
        else
            temp = avg_temp
        end
    end

    if dht ~= nil and sensors.DHT_PIN then
        status, temp, humi = dht.read(sensors.DHT_PIN)
        if status ~= dht.OK then
            log.warn(MODULE, 'error reading from DHT')
            temp = avg_temp
            humi = avg_humi
        else
            temp = temp * 9 / 5 + 32;
        end
    end

    if adc ~= nil and sensors.LIGHT_PIN then
        light = adc.read(sensors.LIGHT_PIN) / 3.5
    end

    avg_temp  = avg_temp  + (temp  - avg_temp ) / sample_count
    avg_humi  = avg_humi  + (humi  - avg_humi ) / sample_count
    avg_light = avg_light + (light - avg_light) / sample_count

    log.trace(MODULE, "raw readings temperature="..temp.." humidity="..humi.." light="..light)

    if countdown_to_report == 0 then
        countdown_to_report = sensors.REPORT_PERIOD
        local msg = {}
        if (bme280 ~= nil and sensors.BME280_PIN_SCL and sensors.BME280_PIN_SDA) or (dht ~= nil and sensors.DHT_PIN) then
            table.insert(msg, string.format('"temperature":%0.1f', avg_temp))
        end
        if dht ~= nil and sensors.DHT_PIN then
            table.insert(msg, string.format('"humidity":%d', avg_humi))
        end
        if adc ~= nil and sensors.LIGHT_PIN then
            table.insert(msg, string.format('"light":%d', avg_light))
        end
        if sensors.zone ~= nil then
            table.insert(msg, '"zone":"' .. sensors.zone .. '"')
        end
        local s = '{' .. table.concat(msg, ',') .. '}'
        log.debug(MODULE, 'logging ' .. s)
        m.client:publish(m.prefix .. "/sensors", s, 0, 0)
    end

    countdown_to_report = countdown_to_report - 1
end)

return sensors
