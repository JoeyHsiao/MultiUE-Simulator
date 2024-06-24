@echo off
setlocal enabledelayedexpansion

set "root_folder=%~dp0"

copy %root_folder%\configs\config_NT_1-1-3.ini %root_folder%\_config.ini

: clean UE logs and tmp files
mkdir %root_folder%\tmp
del /Q %root_folder%\tmp\*
%root_folder%\adb_tool\adb shell "rm *xq3* /data/iperf3* /data/ping* /data/http* /data/ftp* /data/xq3* /data/xq3/* > /dev/null 2>&1"

call "%root_folder%\cmds\cmd_get_config_value.cmd"
call "%root_folder%\cmds\cmd_wait_adb_all.cmd"

call "%root_folder%\cmds\cmd_run_devices_for_http.cmd"
call "%root_folder%\cmds\cmd_run_devices_for_ftp.cmd"


endlocal