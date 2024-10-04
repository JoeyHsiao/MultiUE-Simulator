@echo off
setlocal enabledelayedexpansion

set "root_folder=%~dp0"

copy %root_folder%\configs\config_NT_1-1-3.ini %root_folder%\_config.ini

: clean UE logs and tmp files
mkdir %root_folder%\tmp
del /Q %root_folder%\tmp\*

call "%root_folder%\cmds\cmd_get_config_value.cmd"
call "%root_folder%\cmds\cmd_wait_adb_all.cmd"

set "remove_logs=True"
call "%root_folder%\cmds\cmd_run_devices_for_http.cmd"

set "remove_logs=False"
call "%root_folder%\cmds\cmd_run_devices_for_ftp.cmd"

set "remove_logs=False"
call "%root_folder%\cmds\cmd_run_devices_for_rtt.cmd"


endlocal