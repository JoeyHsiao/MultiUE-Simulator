@echo off
setlocal enabledelayedexpansion

set "device_serial_name=%~1"
set "testing_command=%*"
set "testing_command=!testing_command:%device_serial_name%=!" 

echo %testing_command%

%root_folder%\adb_tool\adb -s %device_serial_name% shell uci set network.wan.mode=1
%root_folder%\adb_tool\adb -s %device_serial_name% shell uci commit network
%root_folder%\adb_tool\adb -s %device_serial_name% shell "/etc/init.d/network restart"
%root_folder%\adb_tool\adb -s %device_serial_name% shell "mipc_wan_cli2 --at_cmd AT+CFUN=1"

echo Waiting network connect ...
:FOR_LOOP_FOR_WAIT_NETWORK_CONNECT
for /f "usebackq delims=" %%b in (`%root_folder%\adb_tool\adb -s %device_serial_name% shell cat /data/xq3/net_ifstatus_state`) do (
    if "%%b"=="0" (
        goto FOR_LOOP_FOR_WAIT_NETWORK_CONNECT
    ) else (
        goto BREAK_FOR_LOOP_FOR_WAIT_NETWORK_CONNECT
    )
)

:BREAK_FOR_LOOP_FOR_WAIT_NETWORK_CONNECT

%root_folder%\adb_tool\adb -s %device_serial_name% shell %testing_command%

endlocal
pause