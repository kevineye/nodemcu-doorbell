local log = {}

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

function log.trace(...) raw_log("TRACE", ...) end
function log.debug(...) raw_log("DEBUG", ...) end
function log.info(...)  raw_log("INFO",  ...) end
function log.warn(...)  raw_log("WARN",  ...) end
function log.error(...) raw_log("ERROR", ...) end
function log.fatal(...) raw_log("FATAL", ...) end

return log
