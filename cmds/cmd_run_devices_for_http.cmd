if "!HTTP_UE_NUM!"=="" (
    exit /B
) else if "!HTTP_UE_NUM!"=="0" (
    exit /B
)
set "need_run_device_num=!HTTP_UE_NUM!"

set "default_http_dl_cmd=mkdir /data/xq3; cd /data/xq3; TESTING_TIMES; do killall curl; cur_time=$(date '+%%Y%%m%%d_%%H%%M%%S'); filename=http_${cur_time}_NAMEDEV.log; echo $filename >> /xq3_logs_file; curl -o /dev/null http://SERVER_IP/DL_FILE_NAME 2>&1 | tee /data/xq3/$filename; if [ "$(cat /var/xq3/net_ifstatus_state)" = "0" ]; then echo "network_disconnect" >> /xq3_logs_file; DO_BREAK fi ;done"
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

echo server_ip=%server_ip%
echo testing_direct=%testing_direct%
echo dl_filenane=%dl_filenane%
echo ul_filesize=%ul_filesize%
echo testing_times=%testing_times%
echo run_daemon=%run_daemon%
echo stop_once_disconnect=%stop_once_disconnect%

call "%root_folder%\cmds\cmd_wait_testing_device.cmd
for %%i in (!can_run_devices!) do (
    echo %%i
    echo type=http > %root_folder%\tmp\xq3_execute_config_%%i
    echo daemon=%run_daemon% >> %root_folder%\tmp\xq3_execute_config_%%i

    if "%testing_direct%" == "DL" (
        set "default_http_cmd_%%i=!default_http_dl_cmd:DL_FILE_NAME=%dl_filenane%!"
    )
    
    set "default_http_cmd_%%i=!default_http_cmd_%%i:SERVER_IP=%server_ip%!"

    if "%testing_times%" == "0" (
        set "default_http_cmd_%%i=!default_http_cmd_%%i:TESTING_TIMES=while true!"
    ) else (
        set "default_http_cmd_%%i=!default_http_cmd_%%i:TESTING_TIMES=for i in $(seq 1 %testing_times%)!"
    )

    if "%stop_once_disconnect%" == "True" (
        set "default_http_cmd_%%i=!default_http_cmd_%%i:DO_BREAK=break;!"
    ) else (
        set "default_http_cmd_%%i=!default_http_cmd_%%i:DO_BREAK=!"
    )

    set "default_http_cmd_%%i=!default_http_cmd_%%i:NAMEDEV=%%i!"

    echo !default_http_cmd_%%i! > %root_folder%\tmp\xq3_execute_%%i

    if "%OTHERS_WAIT_CMD_FINISH%" == "True" (
        start "%%i" /wait cmd /c "%root_folder%\cmds\cmd_start_testing.cmd %%i"
    ) else (
        start "%%i" cmd /c "%root_folder%\cmds\cmd_start_testing.cmd %%i"
    )
)
