@echo off
setlocal enabledelayedexpansion

set "root_folder=%~dp0"

set "iperf_server_ip=10.45.0.1"

call "%root_folder%\cmds\cmd_get_config_value.cmd"
call "%root_folder%\cmds\cmd_wait_adb_all.cmd"

REM Release all devices netwrok
set "device_count=0"
for %%i in (%device_serial_list%) do (
    echo %%i release
    %root_folder%\adb_tool\adb -s %%i shell "ifdown wan > /dev/null 2>&1"
    %root_folder%\adb_tool\adb -s %%i shell "mipc_wan_cli2 --at_cmd AT+CFUN=0 > /dev/null 2>&1"
)

REM Device airplane off and immediately do iperf3 bidirection
for %%i in (%device_serial_list%) do (
    set "testing_command=echo finish"
    start "%%i" cmd /c "%root_folder%\cmds\cmd_run_script_after_network_connect.cmd %%i !testing_command!"
)

endlocal