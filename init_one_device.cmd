
setlocal enabledelayedexpansion

set "root_folder=%~dp0"
call "%root_folder%\cmds\cmd_get_config_value.cmd"

set "device_serial=WU93CKE00029"
echo Wait for device !device_serial!
%root_folder%\adb_tool\adb -s !device_serial! wait-for-device

%root_folder%\adb_tool\adb -s !device_serial! shell "rm *xq3* /data/* /etc/init.d/*xq3* /etc/rc.d/*xq3* > /dev/null 2>&1"

%root_folder%\adb_tool\adb -s !device_serial! shell "uci set system.@system[0].ap_start='0' > /dev/null 2>&1"
%root_folder%\adb_tool\adb -s !device_serial! shell "uci set system.@system[0].gps_start='0' > /dev/null 2>&1"
%root_folder%\adb_tool\adb -s !device_serial! shell "uci set system.@system[0].net_start='0' > /dev/null 2>&1"
%root_folder%\adb_tool\adb -s !device_serial! shell "uci set system.@system[0].md_start='0' > /dev/null 2>&1"
%root_folder%\adb_tool\adb -s !device_serial! shell "uci commit system > /dev/null 2>&1"
%root_folder%\adb_tool\adb -s !device_serial! shell "ubus call uci reload_config > /dev/null 2>&1"

%root_folder%\adb_tool\adb -s !device_serial! shell "rm -rf data/debuglog/ > /dev/null 2>&1"
%root_folder%\adb_tool\adb -s !device_serial! shell "rm -rf data/log/ > /dev/null 2>&1"
%root_folder%\adb_tool\adb -s !device_serial! shell "rm -rf data/logs/ > /dev/null 2>&1"
%root_folder%\adb_tool\adb -s !device_serial! shell "rm -rf data/dmc_data > /dev/null 2>&1"
%root_folder%\adb_tool\adb -s !device_serial! shell "rm -rf data/log/aee_exp > /dev/null 2>&1"
%root_folder%\adb_tool\adb -s !device_serial! shell "rm -rf qciinfo/event_monitor/event.log > /dev/null 2>&1"

%root_folder%\adb_tool\adb -s !device_serial! shell uci set network.wan.rattype=15
%root_folder%\adb_tool\adb -s !device_serial! shell uci set network.wan.mode=1
%root_folder%\adb_tool\adb -s !device_serial! shell "uci commit network > /dev/null 2>&1"

if "%GENERAL_BAND%" == "n78" (
    %root_folder%\adb_tool\adb -s !device_serial! shell "mipc_wan_cli2 --at_cmd AT+EPBSEH=,,,\\\"00000000000000000000200000000000\\\""
) else if "%GENERAL_BAND%" == "n79" (
    %root_folder%\adb_tool\adb -s !device_serial! shell "mipc_wan_cli2 --at_cmd AT+EPBSEH=,,,\\\"0000000000000000000040000000000000\\\""
)

if "%GENERAL_NARFCN%" == "" (
    %root_folder%\adb_tool\adb -s !device_serial! shell "mipc_wan_cli2 --at_cmd at+emmchlck=0"
) else if "%GENERAL_PCI%" == "" (
    %root_folder%\adb_tool\adb -s !device_serial! shell "mipc_wan_cli2 --at_cmd at+emmchlck=0"
) else (
    %root_folder%\adb_tool\adb -s !device_serial! shell "mipc_wan_cli2 --at_cmd at+emmchlck=1,11,0,%GENERAL_NARFCN%,%GENERAL_PCI%"
)

%root_folder%\adb_tool\adb -s !device_serial! push scripts\default_apn.json /etc/

%root_folder%\adb_tool\adb -s !device_serial! push scripts\xq3_monitor_daemon /etc/init.d/
%root_folder%\adb_tool\adb -s !device_serial! shell chmod +x /etc/init.d/xq3_monitor_daemon
%root_folder%\adb_tool\adb -s !device_serial! shell ln -s /etc/init.d/xq3_monitor_daemon /etc/rc.d/S99xq3_monitor_daemon

%root_folder%\adb_tool\adb -s !device_serial! push scripts\xq3_testing /etc/init.d/
%root_folder%\adb_tool\adb -s !device_serial! shell chmod +x /etc/init.d/xq3_testing

%root_folder%\adb_tool\adb -s !device_serial! shell "mtk_usb_tether_off.sh > /dev/null 2>&1"

%root_folder%\adb_tool\adb -s !device_serial! shell reboot -f

endlocal
pause