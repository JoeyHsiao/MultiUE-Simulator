@echo off
setlocal enabledelayedexpansion

set "root_folder=%~dp0"

copy %root_folder%\configs\config_NT_1-2-3.ini %root_folder%\_config.ini

call "%root_folder%\cmds\cmd_get_config_value.cmd"
call "%root_folder%\cmds\cmd_wait_adb_all.cmd"

: clean UE logs and tmp files
mkdir %root_folder%\tmp
del /Q %root_folder%\tmp\*
for /f "skip=1 tokens=1" %%a in ('%root_folder%\adb_tool\adb devices ^| findstr /r /b /c:"[0-9A-Za-z]"') do (
    %root_folder%\adb_tool\adb -s %%a shell "rm *xq3* /data/iperf3* /data/ping* /data/http* /data/ftp* /data/xq3* /data/xq3/* > /dev/null 2>&1"
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
    set "testing_command=echo finish"
    start "%%i" cmd /c "%root_folder%\cmds\cmd_run_script_after_network_connect.cmd %%i !testing_command!"
)

endlocal