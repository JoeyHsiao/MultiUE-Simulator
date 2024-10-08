if "!HTTP_UE_NUM!"=="" (
    exit /B
) else if "!HTTP_UE_NUM!"=="0" (
    exit /B
)
set "need_testing_device_num=!HTTP_UE_NUM!"

set "default_http_dl_cmd=cur_time=$(date '+%%Y%%m%%d_%%H%%M%%S'); filename=http_${cur_time}_NAMEDEV.log; LOG_FILENAME_PRINT curl -o /dev/null http://SERVER_IP/DL_FILE_NAME 2>&1 LOG_PRINT"
: python not support http.server ul yet
: curl -T test http://10.45.0.1:8000/home/ps/test

: print http config settings
set "server_ip=!HTTP_SERVER_IP!"
set "testing_direct=!HTTP_DIRECT!"
set "dl_filenane=!HTTP_DL_FILENAME!"
set "ul_filesize=!HTTP_UL_FILESIZE!"
set "testing_times=!HTTP_TIMES!"
set "run_daemon=!HTTP_RUN_DAEMON!"
set "stop_once_disconnect=!HTTP_STOP_ONCE_DISCONNECT!"

if "%testing_times%" == "" (
    set "testing_times=0"
)

if "%stop_once_disconnect%" == "" (
    set "stop_once_disconnect=False"
)

echo server_ip=%server_ip%
echo testing_direct=%testing_direct%
echo dl_filenane=%dl_filenane%
echo ul_filesize=%ul_filesize%
echo testing_times=%testing_times%
echo run_daemon=%run_daemon%
echo stop_once_disconnect=%stop_once_disconnect%

call "%root_folder%\cmds\cmd_wait_testing_device.cmd

set "index=1"

:HTTP_FOR_LOOP_FOR_RUN
set "index_tmp=1"
for %current_device% in (%free_devices%) do (
    set "current_device=%current_device%"
    if "!index!" == "!index_tmp!" (
        goto HTTP_GET_DEVICE_FINISH
    )
    set /a "index_tmp+=1"
)

:HTTP_GET_DEVICE_FINISH
echo %current_device%

if "%remove_logs%" == "False" (
    echo %current_device% logs keeping ...
) else (
    echo %current_device% logs removing ...
    start "%current_device%" /wait cmd /c "%root_folder%\cmds\cmd_remove_logs.cmd %current_device%"
)

if "%testing_direct%" == "DL" (
    set "default_http_cmd_%current_device%=!default_http_dl_cmd:DL_FILE_NAME=%dl_filenane%!"
)
set "default_http_cmd_%current_device%=!default_http_cmd_%current_device%:SERVER_IP=%server_ip%!"
set "default_http_cmd_%current_device%=!default_http_cmd_%current_device%:NAMEDEV=%current_device%!"

if "%GENERAL_LOG_GENERATE%" == "True" (
    set "default_http_cmd_%current_device%=!default_http_cmd_%current_device%:LOG_FILENAME_PRINT=echo $filename >> /xq3_logs_file;!"
    set "default_http_cmd_%current_device%=!default_http_cmd_%current_device%:LOG_PRINT=| tee /data/xq3/$filename!"
) else (
    set "default_http_cmd_%current_device%=!default_http_cmd_%current_device%:LOG_FILENAME_PRINT=!"
    set "default_http_cmd_%current_device%=!default_http_cmd_%current_device%:LOG_PRINT=!"
)

%root_folder%\adb_tool\adb -s %current_device% shell "echo type=http > xq3_execute_config"
%root_folder%\adb_tool\adb -s %current_device% shell "echo daemon=%run_daemon% >> xq3_execute_config"
%root_folder%\adb_tool\adb -s %current_device% shell "echo testing_times=%testing_times% >> xq3_execute_config"
%root_folder%\adb_tool\adb -s %current_device% shell "echo stop_once_disconnect=%stop_once_disconnect% >> xq3_execute_config"

%root_folder%\adb_tool\adb -s %current_device% shell "echo '!default_http_cmd_%current_device%!' > xq3_execute.sh"

echo %current_device% start testing !!!
if "%OTHERS_WAIT_CMD_FINISH%" == "True" (
    start "%current_device%" /wait cmd /c "%root_folder%\cmds\cmd_start_testing.cmd %current_device% %run_daemon%"
) else (
    start "%current_device%" cmd /c "%root_folder%\cmds\cmd_start_testing.cmd %current_device% %run_daemon%"
)

set /a "index+=1"
if !index! gtr !need_testing_device_num! goto HTTP_FOR_LOOP_FOR_RUN_BREAK

goto HTTP_FOR_LOOP_FOR_RUN

:HTTP_FOR_LOOP_FOR_RUN_BREAK