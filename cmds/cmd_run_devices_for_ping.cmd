if "!PING_UE_NUM!"=="" (
    exit /B
) else if "!PING_UE_NUM!"=="0" (
    exit /B
)
set "need_testing_device_num=!PING_UE_NUM!"

set "default_ping_cmd=cur_time=$(date '+%%Y%%m%%d_%%H%%M%%S'); filename=ping_${cur_time}_NAMEDEV.log; LOG_FILENAME_PRINT ping CMD LOG_PRINT"

: print ping config settings
set "server_ip=!PING_SERVER_IP!"
set "run_daemon=!PING_RUN_DAEMON!"
set "stop_once_disconnect=!PING_STOP_ONCE_DISCONNECT!"

if "%stop_once_disconnect%" == "" (
    set "stop_once_disconnect=False"
)

echo server_ip=%server_ip%
echo run_daemon=%run_daemon%
echo stop_once_disconnect=%stop_once_disconnect%

call "%root_folder%\cmds\cmd_wait_testing_device.cmd

set "index=1"

:PING_FOR_LOOP_FOR_RUN
set "index_tmp=1"
for %%i in (%free_devices%) do (
    set "current_device=%%i"
    if "!index!" == "!index_tmp!" (
        goto PING_GET_DEVICE_FINISH
    )
    set /a "index_tmp+=1"
)

:PING_GET_DEVICE_FINISH
echo %current_device%

if "%remove_logs%" == "False" (
    echo %current_device% logs keeping ...
) else (
    echo %current_device% logs removing ...
    start "%current_device%" /wait cmd /c "%root_folder%\cmds\cmd_remove_logs.cmd %current_device%"
)

set "default_ping_cmd_%current_device%=!default_ping_cmd:CMD=%server_ip%!"
set "default_ping_cmd_%current_device%=!default_ping_cmd_%current_device%:NAMEDEV=%current_device%!"

if "%GENERAL_LOG_GENERATE%" == "True" (
    set "default_ping_cmd_%current_device%=!default_ping_cmd_%current_device%:LOG_FILENAME_PRINT=echo $filename >> /xq3_logs_file;!"
    set "default_ping_cmd_%current_device%=!default_ping_cmd_%current_device%:LOG_PRINT=> /data/xq3/$filename!"
) else (
    set "default_ping_cmd_%current_device%=!default_ping_cmd_%current_device%:LOG_FILENAME_PRINT=!"
    set "default_ping_cmd_%current_device%=!default_ping_cmd_%current_device%:LOG_PRINT=!"
)

%root_folder%\adb_tool\adb -s %current_device% shell "echo type=ping > xq3_execute_config"
%root_folder%\adb_tool\adb -s %current_device% shell "echo daemon=%run_daemon% >> xq3_execute_config"
%root_folder%\adb_tool\adb -s %current_device% shell "echo stop_once_disconnect=%stop_once_disconnect% >> xq3_execute_config"

%root_folder%\adb_tool\adb -s %current_device% shell "echo '!default_ping_cmd_%current_device%!' > xq3_execute.sh"

echo %current_device% start testing !!!
if "%OTHERS_WAIT_CMD_FINISH%" == "True" (
    start "%current_device%" /wait cmd /c "%root_folder%\cmds\cmd_start_testing.cmd %current_device% %run_daemon%"
) else (
    start "%current_device%" cmd /c "%root_folder%\cmds\cmd_start_testing.cmd %current_device% %run_daemon%"
)

set /a "index+=1"
if !index! gtr !need_testing_device_num! goto PING_FOR_LOOP_FOR_RUN_BREAK

goto PING_FOR_LOOP_FOR_RUN

:PING_FOR_LOOP_FOR_RUN_BREAK