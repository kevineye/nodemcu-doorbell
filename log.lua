local log = {}

log.TRACE   = 1
log.DEBUG   = 2
log.INFO    = 3
log.WARN    = 4
log.ERROR   = 5
log.FATAL   = 6
log.NONE    = 7

log.level   = log.DEBUG

local raw_log = function(level, module, message)
    local ts

    if localtime and localtime.initialized then
        ts = localtime.time()
    elseif rtctime then
        ts = rtctime.get()
    end

    if ts then
        local tm = rtctime.epoch2cal(ts)
        ts = string.format(" %02d:%02d:%02d", tm["hour"], tm["min"], tm["sec"])
    else
        ts = ""
    end

    print(string.format("[%-5s%s] %s: %s", level, ts, module, message))
end

function log.trace(...) if log.level <= log.TRACE then raw_log("TRACE", ...) end end
function log.debug(...) if log.level <= log.DEBUG then raw_log("DEBUG", ...) end end
function log.info(...)  if log.level <= log.INFO  then raw_log("INFO",  ...) end end
function log.warn(...)  if log.level <= log.WARN  then raw_log("WARN",  ...) end end
function log.error(...) if log.level <= log.ERROR then raw_log("ERROR", ...) end end
function log.fatal(...) if log.level <= log.FATAL then raw_log("FATAL", ...) end end

return log
