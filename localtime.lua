local MODULE = 'localtime'
local log = require 'log'

localtime = {}
localtime.initialized       = false
localtime.server            = "pool.ntp.org"
localtime.keep_synchronized = true
localtime.tz_offset         = config and config.get('tz_offset')
localtime.debug             = false

if ready ~= nil then ready.not_ready() end

if localtime.tz_offset == nil then
    localtime.tz_offset = -5.0
    log.warn(MODULE, "time zone offset not set; assuming "..localtime.tz_offset)
else
    log.debug(MODULE, "time zone offset set to " .. localtime.tz_offset)
end

log.trace(MODULE, "attempting time synchronization...")
sntp.sync(localtime.server,
    function(sec, usec, server, info)
        localtime.initialized = true
        log.info(MODULE, "time synchronization succeeded with "..server)
        if ready ~= nil then ready.ready() end
    end,
    function()
        log.fatal(MODULE, "time synchronization failed")
    end,
    localtime.keep_synchronized
)

function localtime.is_dst(ts)
    local tm = rtctime.epoch2cal(ts)

    -- jan, feb, dec are never DST
    if tm["mon"] < 3 or tm["mon"] > 11 then
        return false
    end

    -- apr-oct are always DST
    if tm["mon"] > 3 and tm["mon"] < 11 then
        return true
    end

    local previousSunday = tm["day"] - tm["wday"] + 1

    -- in mar, DST if previous sunday was on or after the 8th
    if tm["mon"] == 3 then
        return previousSunday >= 8 and tm["hour"] >= 2
    end

    -- in nov, must be before the first sunday to be dst
    -- that means the previous sunday must be before the 1st
    return previousSunday <= 0 and tm["hour"] < 2
end

function localtime.time()
    local tz = localtime.tz_offset
    local ts = rtctime.get()
    if localtime.is_dst(ts) then
        tz = tz + 1
    end
    return ts + 3600 * tz
end

if localtime.debug then
    tmr.alarm(5, 5000, tmr.ALARM_AUTO, function()
        if localtime.initialized then
            local tm = rtctime.epoch2cal(localtime.time())
            log.debug(MODULE, string.format("time is %04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))
        end
    end)
end

return localtime
