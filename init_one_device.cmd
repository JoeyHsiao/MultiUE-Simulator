@echo off
setlocal enabledelayedexpansion

set "root_folder=%~dp0"
call "%root_folder%\cmds\cmd_get_config_value.cmd"

set "device_serial=WU939PE00064"
echo Wait for device !device_serial!
%root_folder%\adb_tool\adb -s !device_serial! wait-for-device

start "%device_serial%" cmd /c "%root_folder%\cmds\cmd_init_device.cmd start "%device_serial%"

endlocal
pause