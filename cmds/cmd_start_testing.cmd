@echo off
setlocal enabledelayedexpansion

set "device_serial_name=%~1"

set "root_folder=%~dp0"

%root_folder%\..\adb_tool\adb -s %device_serial_name% push %root_folder%\..\scripts\libreadline.so.8.1 /usr/lib/
%root_folder%\..\adb_tool\adb -s %device_serial_name% shell chmod +x /usr/lib/libreadline.so.8.1
%root_folder%\..\adb_tool\adb -s %device_serial_name% shell ln -s /usr/lib/libreadline.so.8.1  /usr/lib/libreadline.so.8

%root_folder%\..\adb_tool\adb -s %device_serial_name% shell killall iperf3 lftp axel

%root_folder%\..\adb_tool\adb -s %device_serial_name% push %root_folder%\..\tmp/xq3_execute_config_%device_serial_name% /xq3_execute_config
%root_folder%\..\adb_tool\adb -s %device_serial_name% shell "sed -i 's/\r//' /xq3_execute_config"
%root_folder%\..\adb_tool\adb -s %device_serial_name% push %root_folder%\..\tmp/xq3_execute_%device_serial_name% xq3_execute.sh
%root_folder%\..\adb_tool\adb -s %device_serial_name% shell "sed -i 's/\r//' /xq3_execute.sh"
%root_folder%\..\adb_tool\adb -s %device_serial_name% shell chmod +x xq3_execute.sh

%root_folder%\..\adb_tool\adb -s %device_serial_name% shell /etc/init.d/xq3_testing run

endlocal