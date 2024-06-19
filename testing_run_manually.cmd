@echo off
setlocal enabledelayedexpansion

set "root_folder=%~dp0"

call "%root_folder%\cmds\cmd_get_config_value.cmd"
call "%root_folder%\cmds\cmd_wait_adb_all.cmd"

del %root_folder%\configs\xq3_execute*

set "run_manually=true"

call "%root_folder%\cmds\cmd_run_devices_for_ping.cmd"

set "iperf_index=1"
:FOR_LOOP_FOR_RUN
echo IPERF%iperf_index%
call "%root_folder%\cmds\cmd_run_devices_for_iperf.cmd"

if !iperf_index! gtr 5 goto END

set /a iperf_index+=1
goto FOR_LOOP_FOR_RUN

:END
endlocal
pause