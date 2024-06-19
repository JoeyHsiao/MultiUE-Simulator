set "device_serial_name=%~1"

%root_folder%\adb_tool\adb -s %device_serial_name% shell "ifdown wan"
%root_folder%\adb_tool\adb -s %device_serial_name% shell "mipc_wan_cli2 --at_cmd AT+CFUN=0"