if "!IPERF%iperf_index%_UE_NUM!"=="" (
    exit /B
) else if "!IPERF%iperf_index%_UE_NUM!"=="0" (
    exit /B
)
set "need_testing_device_num=!IPERF%iperf_index%_UE_NUM!"

set "default_iperf_udp_cmd=cur_time=$(date '+%%Y%%m%%d_%%H%%M%%S'); filename=iperf3_NAMETYPE_NAMEDIRECT_${cur_time}_NAMEDEV.log; LOG_FILENAME_PRINT iperf3 -c CMD_IP -u CMD_PORT CMD_UDP_BITRATE CMD_LENGTH CMD_DIRECT CMD_OMIT CMD_TIME --timestamp='%%Y%%m%%d%%H%%M%%S ' LOG_PRINT"
set "default_iperf_tcp_cmd=cur_time=$(date '+%%Y%%m%%d_%%H%%M%%S'); filename=iperf3_NAMETYPE_NAMEDIRECT_${cur_time}_NAMEDEV.log; LOG_FILENAME_PRINT iperf3 -c CMD_IP CMD_PORT CMD_LENGTH CMD_TCP_PARALLEL CMD_DIRECT CMD_OMIT CMD_TIME --timestamp='%%Y%%m%%d%%H%%M%%S ' LOG_PRINT"

: CMD_IP CMD_TYPE CMD_PORT CMD_UDP_BITRATE CMD_TCP_PARALLEL CMD_DIRECT CMD_OMIT CMD_TIME
set "server_ip=!IPERF%iperf_index%_SERVER_IP!"
set "protocol_type=!IPERF%iperf_index%_TYPE!"
set /a "iperf_port=IPERF%iperf_index%_START_PORT+0"
set "udp_bitrate=!IPERF%iperf_index%_UDP_BITRATE!"
set "tcp_parallel=!IPERF%iperf_index%_TCP_PARALLEL!"
set "testing_direct=!IPERF%iperf_index%_DIRECT!"
set "testing_omit=!IPERF%iperf_index%_OMIT!"
set "testing_time=!IPERF%iperf_index%_TIME!"
set "testing_times=!IPERF%iperf_index%_TIMES!"
set "run_daemon=!IPERF%iperf_index%_RUN_DAEMON!"
set "length=!IPERF%iperf_index%_LENGTH!"
set "stop_once_disconnect=!IPERF%iperf_index%_STOP_ONCE_DISCONNECT!"

if "%testing_time%" == "" (
    set "testing_time=0"
)

if "%testing_times%" == "" (
    set "testing_times=0"
)

if "%stop_once_disconnect%" == "" (
    set "stop_once_disconnect=False"
)

echo iperf_%iperf_index%
echo server_ip=%server_ip%
echo protocol_type=%protocol_type%
echo iperf_port=%iperf_port%
echo udp_bitrate=%udp_bitrate%
echo tcp_parallel=%tcp_parallel%
echo testing_direct=%testing_direct%
echo testing_omit=%testing_omit%
echo testing_time=%testing_time%
echo testing_times=%testing_times%
echo length=%length%
echo run_daemon=%run_daemon%
echo stop_once_disconnect=%stop_once_disconnect%

call "%root_folder%\cmds\cmd_wait_testing_device.cmd

set /a "portnum=IPERF%iperf_index%_START_PORT+0"
set "index=1"

:IPERF_FOR_LOOP_FOR_RUN
set "index_tmp=1"
for %%i in (%free_devices%) do (
    set "current_device=%%i"
    if "!index!" == "!index_tmp!" (
        goto IPERF_GET_DEVICE_FINISH
    )
    set /a "index_tmp+=1"
)

:IPERF_GET_DEVICE_FINISH
echo %current_device%

if "%remove_logs%" == "False" (
    echo %current_device% logs keeping ...
) else (
    echo %current_device% logs removing ...
    start "%current_device%" /wait cmd /c "%root_folder%\cmds\cmd_remove_logs.cmd %current_device%"
)

set "test_protocol="
set "test_driect="

if "%protocol_type%" == "UDP" (
    set "default_iperf_cmd_%current_device%=!default_iperf_udp_cmd:NAMETYPE=UDP!"
    set "test_protocol=UDP"
) else (
    set "default_iperf_cmd_%current_device%=!default_iperf_tcp_cmd:NAMETYPE=TCP!"
    set "test_protocol=TCP"
)

set "default_iperf_cmd_%current_device%=!default_iperf_cmd_%current_device%:CMD_IP=%server_ip%!"
set "default_iperf_cmd_%current_device%=!default_iperf_cmd_%current_device%:CMD_PORT=-p %iperf_port%!"

if "%length%" == "" (
    set "default_iperf_cmd_%current_device%=!default_iperf_cmd_%current_device%:CMD_LENGTH=!"
) else (
    set "default_iperf_cmd_%current_device%=!default_iperf_cmd_%current_device%:CMD_LENGTH=-l %length%!"
)

if "%udp_bitrate%" == "" (
    set "default_iperf_cmd_%current_device%=!default_iperf_cmd_%current_device%:CMD_UDP_BITRATE=!"
) else (
    set "default_iperf_cmd_%current_device%=!default_iperf_cmd_%current_device%:CMD_UDP_BITRATE=-b %udp_bitrate%!"
)

if "%tcp_parallel%" == "0" (
    set "default_iperf_cmd_%current_device%=!default_iperf_cmd_%current_device%:CMD_TCP_PARALLEL=!"
) else if "!IPERF%iperf_index%_TCP_PARALLEL!" == "" (
    set "default_iperf_cmd_%current_device%=!default_iperf_cmd_%current_device%:CMD_TCP_PARALLEL=!"
) else (
    set "default_iperf_cmd_%current_device%=!default_iperf_cmd_%current_device%:CMD_TCP_PARALLEL=-P %tcp_parallel%!"
)

if "%testing_direct%" == "DL" (
    set "default_iperf_cmd_%current_device%=!default_iperf_cmd_%current_device%:CMD_DIRECT=-R!"
    set "default_iperf_cmd_%current_device%=!default_iperf_cmd_%current_device%:NAMEDIRECT=DL!"
    set "test_driect=DL"
) else if "%testing_direct%" == "UL" (
    set "default_iperf_cmd_%current_device%=!default_iperf_cmd_%current_device%:CMD_DIRECT=!"
    set "default_iperf_cmd_%current_device%=!default_iperf_cmd_%current_device%:NAMEDIRECT=UL!"
    set "test_driect=UL"
) else (
    set "default_iperf_cmd_%current_device%=!default_iperf_cmd_%current_device%:CMD_DIRECT=--bidir!"
    set "default_iperf_cmd_%current_device%=!default_iperf_cmd_%current_device%:NAMEDIRECT=BIDIR!"
    set "test_driect=BIDIR"
)

if "%testing_omit%" == "0" (
    set "default_iperf_cmd_%current_device%=!default_iperf_cmd_%current_device%:CMD_OMIT=!"
) else if "%testing_omit%" == "" (
    set "default_iperf_cmd_%current_device%=!default_iperf_cmd_%current_device%:CMD_OMIT=!"
) else (
    set "default_iperf_cmd_%current_device%=!default_iperf_cmd_%current_device%:CMD_OMIT=-O %testing_omit%!"
)

if "%testing_time%" == "0" (
    set "default_iperf_cmd_%current_device%=!default_iperf_cmd_%current_device%:CMD_TIME=-t 86400!"
) else (
    set "default_iperf_cmd_%current_device%=!default_iperf_cmd_%current_device%:CMD_TIME=-t %testing_time%!"
)

set "test_type=!test_protocol!-!test_driect!"

set "default_iperf_cmd_%current_device%=!default_iperf_cmd_%current_device%:NAMEDEV=%current_device%!"

if "%GENERAL_LOG_GENERATE%" == "True" (
    set "default_iperf_cmd_%current_device%=!default_iperf_cmd_%current_device%:LOG_FILENAME_PRINT=echo $filename >> /xq3_logs_file;!"
    set "default_iperf_cmd_%current_device%=!default_iperf_cmd_%current_device%:LOG_PRINT=--logfile /data/xq3/$filename!"
) else (
    set "default_iperf_cmd_%current_device%=!default_iperf_cmd_%current_device%:LOG_FILENAME_PRINT=!"
    set "default_iperf_cmd_%current_device%=!default_iperf_cmd_%current_device%:LOG_PRINT=!"
)

%root_folder%\adb_tool\adb -s %current_device% shell "echo type=!test_type! > xq3_execute_config"
%root_folder%\adb_tool\adb -s %current_device% shell "echo port=!iperf_port! >> xq3_execute_config"
%root_folder%\adb_tool\adb -s %current_device% shell "echo daemon=%run_daemon% >> xq3_execute_config"
%root_folder%\adb_tool\adb -s %current_device% shell "echo testing_times=%testing_times% >> xq3_execute_config"
%root_folder%\adb_tool\adb -s %current_device% shell "echo stop_once_disconnect=%stop_once_disconnect% >> xq3_execute_config"

%root_folder%\adb_tool\adb -s %current_device% shell "echo '!default_iperf_cmd_%current_device%!' > xq3_execute.sh"

echo %current_device% start testing !!!
if "%OTHERS_WAIT_CMD_FINISH%" == "True" (
    start "%current_device%" /wait cmd /c "%root_folder%\cmds\cmd_start_testing.cmd %current_device% %run_daemon%"
) else (
    start "%current_device%" cmd /c "%root_folder%\cmds\cmd_start_testing.cmd %current_device% %run_daemon%"
)

set /a "iperf_port+=1"
set /a "index+=1"
if !index! gtr !IPERF%iperf_index%_UE_NUM! goto IPERF_FOR_LOOP_FOR_RUN_BREAK

if "!run_manually!" == "true" (
    pause
)
goto IPERF_FOR_LOOP_FOR_RUN

:IPERF_FOR_LOOP_FOR_RUN_BREAK