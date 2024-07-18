@echo off
setlocal enabledelayedexpansion

set "device_serial_name=%~1"

set "root_folder=%~dp0\.."

%root_folder%\adb_tool\adb -s %device_serial_name% shell "rm -rf *xq3* /data/xq3/* > /dev/null 2>&1"

%root_folder%\adb_tool\adb -s %device_serial_name% shell uci set network.wan.rattype=15
%root_folder%\adb_tool\adb -s %device_serial_name% shell uci set network.wan.mode=1
%root_folder%\adb_tool\adb -s %device_serial_name% shell "uci commit network > /dev/null 2>&1"

if "%GENERAL_BAND%" == "n78" (
    %root_folder%\adb_tool\adb -s %device_serial_name% shell "mipc_wan_cli2 --at_cmd AT+EPBSEH=,,,\\\"00000000000000000000200000000000\\\""
) else if "%GENERAL_BAND%" == "n79" (
    %root_folder%\adb_tool\adb -s %device_serial_name% shell "mipc_wan_cli2 --at_cmd AT+EPBSEH=,,,\\\"0000000000000000000040000000000000\\\""
)

if "%GENERAL_NARFCN%" == "" (
    %root_folder%\adb_tool\adb -s %device_serial_name% shell "mipc_wan_cli2 --at_cmd at+emmchlck=0"
) else if "%GENERAL_PCI%" == "" (
    %root_folder%\adb_tool\adb -s %device_serial_name% shell "mipc_wan_cli2 --at_cmd at+emmchlck=0"
) else (
    %root_folder%\adb_tool\adb -s %device_serial_name% shell "mipc_wan_cli2 --at_cmd at+emmchlck=1,11,0,%GENERAL_NARFCN%,%GENERAL_PCI%"
)

%root_folder%\adb_tool\adb -s %device_serial_name% push %root_folder%\scripts\default_apn.json /etc/
%root_folder%\adb_tool\adb -s %device_serial_name% shell "sed -i 's/\r//' /etc/default_apn.json"

%root_folder%\adb_tool\adb -s %device_serial_name% push %root_folder%\scripts\xq3_monitor_daemon /etc/init.d/
%root_folder%\adb_tool\adb -s %device_serial_name% shell "sed -i 's/\r//' /etc/init.d/xq3_monitor_daemon"
%root_folder%\adb_tool\adb -s %device_serial_name% shell chmod +x /etc/init.d/xq3_monitor_daemon
%root_folder%\adb_tool\adb -s %device_serial_name% shell ln -s /etc/init.d/xq3_monitor_daemon /etc/rc.d/S99xq3_monitor_daemon

%root_folder%\adb_tool\adb -s %device_serial_name% push %root_folder%\scripts\xq3_testing /etc/init.d/
%root_folder%\adb_tool\adb -s %device_serial_name% shell "sed -i 's/\r//' /etc/init.d/xq3_testing"
%root_folder%\adb_tool\adb -s %device_serial_name% shell chmod +x /etc/init.d/xq3_testing

%root_folder%\adb_tool\adb -s %device_serial_name% push %root_folder%\scripts\lftp /usr/bin/
%root_folder%\adb_tool\adb -s %device_serial_name% shell chmod +x /usr/bin/lftp
%root_folder%\adb_tool\adb -s %device_serial_name% push %root_folder%\scripts\libreadline.so.8.1 /usr/lib/
%root_folder%\adb_tool\adb -s %device_serial_name% shell chmod +x /usr/lib/libreadline.so.8.1
%root_folder%\adb_tool\adb -s %device_serial_name% shell ln -s /usr/lib/libreadline.so.8.1  /usr/lib/libreadline.so.8

%root_folder%\adb_tool\adb -s %device_serial_name% push %root_folder%\scripts\axel_2.17.14 /usr/bin/axel
%root_folder%\adb_tool\adb -s %device_serial_name% shell chmod +x /usr/bin/axel

%root_folder%\adb_tool\adb -s %device_serial_name% shell "mtk_usb_tether_off.sh > /dev/null 2>&1"

%root_folder%\adb_tool\adb -s %device_serial_name% shell reboot -f

endlocal
pause