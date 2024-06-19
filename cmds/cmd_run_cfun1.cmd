set "device_serial_name=%~1"

%root_folder%\adb_tool\adb -s %device_serial_name% shell uci set network.wan.mode=1
%root_folder%\adb_tool\adb -s %device_serial_name% shell uci commit network
%root_folder%\adb_tool\adb -s %device_serial_name% shell "/etc/init.d/network restart"
%root_folder%\adb_tool\adb -s %device_serial_name% shell "mipc_wan_cli2 --at_cmd AT+CFUN=1"