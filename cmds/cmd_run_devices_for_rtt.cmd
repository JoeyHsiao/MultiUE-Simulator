if "!PING_UE_NUM!"=="" (
    exit /B
) else if "!PING_UE_NUM!"=="0" (
    exit /B
)
set "need_run_device_num=!PING_UE_NUM!"

set "default_rtt_cmd=cur_time=$(date '+%%Y%%m%%d_%%H%%M%%S'); filename=rtt_${cur_time}_NAMEDEV.log; echo $filename >> xq3_logs_file; netperf -t TYPE_RR -H SERVER_IP -l TESTING_TIME -o min_latency,max_latency,mean_latency -- -r TEST_SIZE,TEST_SIZE > /data/$filename"

: print rtt config settings
set "server_ip=!RTT_SERVER_IP!"
set "protocol_type=!RTT_TYPE!"
set "testing_time=!RTT_TIME!"
set "testing_size=!RTT_SIZE!"
set "run_daemon=!RTT_RUN_DAEMON!"

echo server_ip=%server_ip%
echo protocol_type=%protocol_type%
echo testing_time=%testing_time%
echo testing_size=%testing_size%
echo run_daemon=%run_daemon%

call "%root_folder%\cmds\cmd_wait_testing_device.cmd
for %%i in (!can_run_devices!) do (
    echo %%i
    echo type=rtt > %root_folder%\tmp\xq3_execute_config_%%i
    echo daemon=%run_daemon% >> %root_folder%\tmp\xq3_execute_config_%%i

    set "default_rtt_cmd_%%i=!default_rtt_cmd:SERVER_IP=%server_ip%!"
    set "default_rtt_cmd_%%i=!default_rtt_cmd:TYPE=%protocol_type%!"
    set "default_rtt_cmd_%%i=!default_rtt_cmd:TESTING_TIME=%testing_time%!"
    set "default_rtt_cmd_%%i=!default_rtt_cmd:TEST_SIZE=%testing_size%!"

    set "default_rtt_cmd_%%i=!default_rtt_cmd_%%i:NAMEDEV=%%i!"
    echo !default_rtt_cmd_%%i! > %root_folder%\tmp\xq3_execute_%%i

    if "%OTHERS_WAIT_CMD_FINISH%" == "True" (
        start "%%i" /wait cmd /c "%root_folder%\cmds\cmd_start_testing.cmd %%i"
    ) else (
        start "%%i" cmd /c "%root_folder%\cmds\cmd_start_testing.cmd %%i"
    )
)
