@echo off
setlocal enabledelayedexpansion

set "root_folder=%~dp0"

if EXIST "%root_folder%\_config.ini" (
    echo .
) else (
    copy %root_folder%\configs\config_general.ini %root_folder%\_config.ini
)

call "%root_folder%\cmds\cmd_get_config_value.cmd"
call "%root_folder%\cmds\cmd_wait_adb_all.cmd"

: clean UE logs and tmp files
mkdir %root_folder%\tmp
del /Q %root_folder%\tmp\*

set "remove_logs=True"

echo .
echo ping
call "%root_folder%\cmds\cmd_run_devices_for_ping.cmd"

echo .
echo ftp
call "%root_folder%\cmds\cmd_run_devices_for_ftp.cmd"

echo .
echo http
call "%root_folder%\cmds\cmd_run_devices_for_http.cmd"

set "iperf_index=1"
:FOR_LOOP_FOR_RUN
echo .
echo IPERF%iperf_index%
call "%root_folder%\cmds\cmd_run_devices_for_iperf.cmd"

if !iperf_index! gtr 4 goto END

set /a iperf_index+=1
goto FOR_LOOP_FOR_RUN

:END
endlocal
pause