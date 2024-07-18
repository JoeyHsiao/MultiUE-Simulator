@echo off
setlocal enabledelayedexpansion

set "root_folder=%~dp0"

set "using_port=5001"
set "iperf_server_ip=10.45.0.1"
set "keep_time=300"

call "%root_folder%\cmds\cmd_get_config_value.cmd"
call "%root_folder%\cmds\cmd_wait_adb_all.cmd"

: clean UE logs and tmp files 
del /Q %root_folder%\tmp\*
for /f "skip=1 tokens=1" %%a in ('%root_folder%\adb_tool\adb devices ^| findstr /r /b /c:"[0-9A-Za-z]"') do (
    %root_folder%\adb_tool\adb -s %%a shell "rm *xq3* /data/xq3* > /dev/null 2>&1"
)

REM Release all devices netwrok
set "device_count=0"
for %%i in (%device_serial_list%) do (
    echo %%i release
    %root_folder%\adb_tool\adb -s %%i shell "ifdown wan > /dev/null 2>&1"
    %root_folder%\adb_tool\adb -s %%i shell "mipc_wan_cli2 --at_cmd AT+CFUN=0 > /dev/null 2>&1"
)

REM Device airplane off and immediately do iperf3 bidirection
for %%i in (%device_serial_list%) do (
    set "device_serial=%%i"
    set "testing_command=while true; do iperf3 -c %iperf_server_ip% -p !using_port! -t 86400 --bidir -u -b 30M; done"
    start "%%i" cmd /c "%root_folder%\cmds\cmd_run_script_after_network_connect.cmd %%i !testing_command!"
    set /a "using_port+=1"
    timeout /t 1 /nobreak >nul
)

:CHECK_NETWORK_BEFORE_TIMING
call "%root_folder%\cmds\cmd_check_network_status.cmd"
if "!connect_network_devices_num!" == "!GENERAL_TOTAL_UE_NUM!" (
    echo All devices connect successfully, start timing
) else (
    set "count_tmp=0"
    set "devices_state_output="
    for %%i in (!devices_state!) do (
        set /a count_tmp+=1

        if !count_tmp! equ 4 (
            set "devices_state_output=!devices_state_output!"
        ) else if defined devices_state_output (
            set "devices_state_output=!devices_state_output!___(%%i)"
        ) else (
            set "devices_state_output=(%%i)"
        )

        if !count_tmp! equ 4 (
            echo !devices_state_output!
            set "devices_state_output="
            set /a count_tmp=0
        )
    )
    ping -n 3 127.0.0.1 >nul
    goto CHECK_NETWORK_BEFORE_TIMING
)

for /L %%i in (1,1,%keep_time%) do (
    timeout /t 1 /nobreak >nul
)

call "%root_folder%\cmds\cmd_check_network_status.cmd"
if "!connect_network_devices_num!" == "!GENERAL_TOTAL_UE_NUM!" (
    echo Testing Success!!!
) else (
    echo Testing Failed!!!
)

endlocal
pause