if "!PING_UE_NUM!"=="" (
    exit /B
) else if "!PING_UE_NUM!"=="0" (
    exit /B
)
set "need_run_device_num=!PING_UE_NUM!"

set "default_ping_cmd=cur_time=$(date '+%%Y%%m%%d_%%H%%M%%S'); filename=ping_${cur_time}_NAMEDEV.log; echo $filename >> xq3_logs_file; ping CMD > /data/$filename"

: print ping config settings
set "server_ip=!FTP_SERVER_IP!"
set "run_daemon=!FTP_RUN_DAEMON!"

echo server_ip=%server_ip%
echo run_daemon=%run_daemon%

call "%root_folder%\cmds\cmd_wait_testing_device.cmd
for %%i in (!can_run_devices!) do (
    echo %%i
    echo type=ping > %root_folder%\tmp\xq3_execute_config_%%i
    echo daemon=%run_daemon% >> %root_folder%\tmp\xq3_execute_config_%%i

    set "default_ping_cmd_%%i=!default_ping_cmd:CMD=%server_ip%!"
    set "default_ping_cmd_%%i=!default_ping_cmd_%%i:NAMEDEV=%%i!"
    echo !default_ping_cmd_%%i! > %root_folder%\tmp\xq3_execute_%%i

    if "%OTHERS_WAIT_CMD_FINISH%" == "True" (
        start "%%i" /wait cmd /c "%root_folder%\cmds\cmd_start_testing.cmd %%i"
    ) else (
        start "%%i" cmd /c "%root_folder%\cmds\cmd_start_testing.cmd %%i"
    )
)
