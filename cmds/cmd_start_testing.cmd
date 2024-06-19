@echo off
setlocal enabledelayedexpansion

set "device_serial_name=%~1"

set "root_folder=%~dp0"

%root_folder%\..\adb_tool\adb -s %device_serial_name% push %root_folder%\..\tmp/xq3_execute_config_%device_serial_name% /xq3_execute_config
%root_folder%\..\adb_tool\adb -s %device_serial_name% push %root_folder%\..\tmp/xq3_execute_%device_serial_name% xq3_execute.sh
%root_folder%\..\adb_tool\adb -s %device_serial_name% push %root_folder%\..\scripts/xq3_remove_CRLF.sh /
%root_folder%\..\adb_tool\adb -s %device_serial_name% shell chmod +x xq3_execute.sh
%root_folder%\..\adb_tool\adb -s %device_serial_name% shell chmod +x xq3_remove_CRLF.sh

%root_folder%\..\adb_tool\adb -s %device_serial_name% shell /etc/init.d/xq3_testing run

endlocal