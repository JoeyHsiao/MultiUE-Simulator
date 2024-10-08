@echo off
setlocal enabledelayedexpansion

set "device_serial_name=%~1"
set "run_daemon=%~2"
set "root_folder=%~dp0"

%root_folder%\..\adb_tool\adb -s %device_serial_name% push %root_folder%\..\scripts\libreadline.so.8.1 /usr/lib/
%root_folder%\..\adb_tool\adb -s %device_serial_name% shell chmod +x /usr/lib/libreadline.so.8.1
%root_folder%\..\adb_tool\adb -s %device_serial_name% shell ln -s /usr/lib/libreadline.so.8.1  /usr/lib/libreadline.so.8

%root_folder%\..\adb_tool\adb -s %device_serial_name% shell killall iperf3 lftp axel curl ping

%root_folder%\..\adb_tool\adb -s %device_serial_name% shell "sed -i 's/\r//' /xq3_execute_config"
%root_folder%\..\adb_tool\adb -s %device_serial_name% shell "sed -i 's/\r//' /xq3_execute.sh"
%root_folder%\..\adb_tool\adb -s %device_serial_name% shell chmod +x xq3_execute.sh

if "%run_daemon%" == "True" (
    %root_folder%\..\adb_tool\adb -s %device_serial_name% shell "start-stop-daemon -b -S -x /etc/init.d/xq3_testing run"
) else (
    %root_folder%\..\adb_tool\adb -s %device_serial_name% shell "/etc/init.d/xq3_testing run"
)

endlocal
