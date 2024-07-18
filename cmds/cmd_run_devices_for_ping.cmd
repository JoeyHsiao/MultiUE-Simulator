if "!PING_UE_NUM!"=="" (
    exit /B
) else if "!PING_UE_NUM!"=="0" (
    exit /B
)
set "need_run_device_num=!PING_UE_NUM!"

set "default_ping_cmd=mkdir /data/xq3; WHILE_FOR_LOOP; do killall ping; cur_time=$(date '+%%Y%%m%%d_%%H%%M%%S'); filename=ping_${cur_time}_NAMEDEV.log; echo $filename >> xq3_logs_file; ping CMD > /data/xq3/$filename; if [ "$(cat /var/xq3/net_ifstatus_state)" = "0" ]; then echo "network_disconnect" >> /xq3_logs_file; DO_BREAK fi ;done"

: print ping config settings
set "server_ip=!PING_SERVER_IP!"
set "run_daemon=!PING_RUN_DAEMON!"
set "stop_once_disconnect=!PING_STOP_ONCE_DISCONNECT!"

echo server_ip=%server_ip%
echo run_daemon=%run_daemon%
echo stop_once_disconnect=%stop_once_disconnect%

call "%root_folder%\cmds\cmd_wait_testing_device.cmd
for %%i in (!can_run_devices!) do (
    echo %%i
    echo type=ping > %root_folder%\tmp\xq3_execute_config_%%i
    echo daemon=%run_daemon% >> %root_folder%\tmp\xq3_execute_config_%%i

    set "default_ping_cmd_%%i=!default_ping_cmd:CMD=%server_ip%!"

    if "%stop_once_disconnect%" == "True" (
        set "default_ping_cmd_%%i=!default_ping_cmd_%%i:WHILE_FOR_LOOP=for i in $(seq 1 1)!"
        set "default_ping_cmd_%%i=!default_ping_cmd_%%i:DO_BREAK=break;!"
    ) else (
        set "default_ping_cmd_%%i=!default_ping_cmd_%%i:WHILE_FOR_LOOP=while true!"
        set "default_ping_cmd_%%i=!default_ping_cmd_%%i:DO_BREAK=!"
    )

    set "default_ping_cmd_%%i=!default_ping_cmd_%%i:NAMEDEV=%%i!"
    echo !default_ping_cmd_%%i! > %root_folder%\tmp\xq3_execute_%%i

    if "%OTHERS_WAIT_CMD_FINISH%" == "True" (
        start "%%i" /wait cmd /c "%root_folder%\cmds\cmd_start_testing.cmd %%i"
    ) else (
        start "%%i" cmd /c "%root_folder%\cmds\cmd_start_testing.cmd %%i"
    )
)
