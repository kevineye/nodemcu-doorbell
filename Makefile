SRC_FILES := \
    lib/config.lua \
    lib/ifttt.lua \
    lib/init.lua \
    lib/log.lua \
    lib/mqtt-connect.lua \
    lib/ready.lua \
    lib/telnet.lua \
    lib/wifi-connect.lua \
    app.lua \
    doorbell.lua \
    config.json

include lib/Makefile.mk
