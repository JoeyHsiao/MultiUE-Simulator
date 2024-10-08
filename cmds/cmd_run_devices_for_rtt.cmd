if "!RTT_UE_NUM!"=="" (
    exit /B
) else if "!RTT_UE_NUM!"=="0" (
    exit /B
)
set "need_testing_device_num=!RTT_UE_NUM!"

set "default_rtt_cmd=cur_time=$(date '+%%Y%%m%%d_%%H%%M%%S'); filename=rtt_${cur_time}_NAMEDEV.log; LOG_FILENAME_PRINT netperf -t TYPE_RR -H SERVER_IP -l TESTING_TIME -o min_latency,max_latency,mean_latency -- -r TEST_SIZE,TEST_SIZE LOG_PRINT"

: print rtt config settings
set "server_ip=!RTT_SERVER_IP!"
set "protocol_type=!RTT_TYPE!"
set "testing_time=!RTT_TIME!"
set "testing_size=!RTT_SIZE!"
set "run_daemon=!RTT_RUN_DAEMON!"

if "%stop_once_disconnect%" == "" (
    set "stop_once_disconnect=False"
)

echo server_ip=%server_ip%
echo protocol_type=%protocol_type%
echo testing_time=%testing_time%
echo testing_size=%testing_size%
echo run_daemon=%run_daemon%
echo stop_once_disconnect=%stop_once_disconnect%

call "%root_folder%\cmds\cmd_wait_testing_device.cmd

set "index=1"

:RTT_FOR_LOOP_FOR_RUN
set "index_tmp=1"
for %current_device% in (%free_devices%) do (
    set "current_device=%current_device%"
    if "!index!" == "!index_tmp!" (
        goto RTT_GET_DEVICE_FINISH
    )
    set /a "index_tmp+=1"
)

:RTT_GET_DEVICE_FINISH
echo %current_device%

if "%remove_logs%" == "False" (
    echo %current_device% logs keeping ...
) else (
    echo %current_device% logs removing ...
    start "%current_device%" /wait cmd /c "%root_folder%\cmds\cmd_remove_logs.cmd %current_device%"
)

set "default_rtt_cmd_%current_device%=!default_rtt_cmd:SERVER_IP=%server_ip%!"
set "default_rtt_cmd_%current_device%=!default_rtt_cmd:TYPE=%protocol_type%!"
set "default_rtt_cmd_%current_device%=!default_rtt_cmd:TESTING_TIME=%testing_time%!"
set "default_rtt_cmd_%current_device%=!default_rtt_cmd:TEST_SIZE=%testing_size%!"
set "default_rtt_cmd_%current_device%=!default_rtt_cmd_%current_device%:NAMEDEV=%current_device%!"

if "%GENERAL_LOG_GENERATE%" == "True" (
    set "default_rtt_cmd_%current_device%=!default_rtt_cmd_%current_device%:LOG_FILENAME_PRINT=echo $filename >> /xq3_logs_file;!"
    set "default_rtt_cmd_%current_device%=!default_rtt_cmd_%current_device%:LOG_PRINT=> /data/xq3/$filename!"
) else (
    set "default_rtt_cmd_%current_device%=!default_rtt_cmd_%current_device%:LOG_FILENAME_PRINT=!"
    set "default_rtt_cmd_%current_device%=!default_rtt_cmd_%current_device%:LOG_PRINT=!"
)

%root_folder%\adb_tool\adb -s %current_device% shell "echo type=rtt > xq3_execute_config"
%root_folder%\adb_tool\adb -s %current_device% shell "echo daemon=%run_daemon% >> xq3_execute_config"
%root_folder%\adb_tool\adb -s %current_device% shell "echo stop_once_disconnect=%stop_once_disconnect% >> xq3_execute_config"

%root_folder%\adb_tool\adb -s %current_device% shell "echo '!default_rtt_cmd_%current_device%!' > xq3_execute.sh"

echo %current_device% start testing !!!
if "%OTHERS_WAIT_CMD_FINISH%" == "True" (
    start "%current_device%" /wait cmd /c "%root_folder%\cmds\cmd_start_testing.cmd %current_device% %run_daemon%"
) else (
    start "%current_device%" cmd /c "%root_folder%\cmds\cmd_start_testing.cmd %current_device% %run_daemon%"
)

set /a "index+=1"
if !index! gtr !need_testing_device_num! goto RTT_FOR_LOOP_FOR_RUN_BREAK

goto RTT_FOR_LOOP_FOR_RUN

:RTT_FOR_LOOP_FOR_RUN_BREAK