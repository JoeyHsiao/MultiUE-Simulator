@echo off
setlocal enabledelayedexpansion

set "root_folder=%~dp0"

copy %root_folder%\configs\config_NT_1-3-1.ini %root_folder%\_config.ini

call "%root_folder%\cmds\cmd_get_config_value.cmd"
call "%root_folder%\cmds\cmd_wait_adb_all.cmd"

: clean UE logs and tmp files
mkdir %root_folder%\tmp
del /Q %root_folder%\tmp\*
for /f "skip=1 tokens=1" %%a in ('%root_folder%\adb_tool\adb devices ^| findstr /r /b /c:"[0-9A-Za-z]"') do (
    %root_folder%\adb_tool\adb -s %%a shell "rm *xq3* /data/xq3/* > /dev/null 2>&1"
)

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