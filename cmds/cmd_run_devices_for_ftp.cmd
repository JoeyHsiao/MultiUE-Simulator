if "!FTP_UE_NUM!"=="" (
    exit /B
) else if "!FTP_UE_NUM!"=="0" (
    exit /B
)
set "need_testing_device_num=!FTP_UE_NUM!"

set "default_ftp_dl_cmd=cur_time=$(date '+%%Y%%m%%d_%%H%%M%%S'); filename=ftp_${cur_time}_NAMEDEV.log; LOG_FILENAME_PRINT lftp -u FTP_ACCOUNT,FTP_PWD SERVER_IP -e "get 'FTP_DL_FILENAME'; quit" LOG_PRINT; rm FTP_DL_FILENAME;"
set "default_ftp_ul_cmd=dd if=/dev/zero of=xq3_ftp_ul_NAMEDEV bs=FTP_UL_FILESIZE count=1; cur_time=$(date '+%%Y%%m%%d_%%H%%M%%S'); filename=ftp_${cur_time}_NAMEDEV.log; LOG_FILENAME_PRINT lftp -u FTP_ACCOUNT,FTP_PWD SERVER_IP -e "put 'xq3_ftp_ul_NAMEDEV'; quit" LOG_PRINT;"
: python not support ftp.server ul yet
: curl -T test ftp://10.45.0.1:8000/home/ps/test

: print ftp config settings
set "server_ip=!FTP_SERVER_IP!"
set "ftp_account=!FTP_ACCOUNT!"
set "ftp_pws=!FTP_PWD!"
set "testing_direct=!FTP_DIRECT!"
set "dl_filename=!FTP_DL_FILENAME!"
set "ul_filesize=!FTP_UL_FILESIZE!"
set "testing_times=!FTP_TIMES!"
set "run_daemon=!FTP_RUN_DAEMON!"
set "stop_once_disconnect=!FTP_STOP_ONCE_DISCONNECT!"

if "%testing_times%" == "" (
    set "testing_times=0"
)

if "%stop_once_disconnect%" == "" (
    set "stop_once_disconnect=False"
)

echo server_ip=%server_ip%
echo ftp_account=%ftp_account%
echo ftp_pws=%ftp_pws%
echo testing_direct=%testing_direct%
echo dl_filename=%dl_filename%
echo ul_filesize=%ul_filesize%
echo testing_times=%testing_times%
echo run_daemon=%run_daemon%
echo stop_once_disconnect=%stop_once_disconnect%

call "%root_folder%\cmds\cmd_wait_testing_device.cmd

set "index=1"

:FTP_FOR_LOOP_FOR_RUN
set "index_tmp=1"
for %%i in (%free_devices%) do (
    set "current_device=%%i"
    if "!index!" == "!index_tmp!" (
        goto FTP_GET_DEVICE_FINISH
    )
    set /a "index_tmp+=1"
)

:FTP_GET_DEVICE_FINISH
echo %current_device%

if "%remove_logs%" == "False" (
    echo %current_device% logs keeping ...
) else (
    echo %current_device% logs removing ...
    start "%current_device%" /wait cmd /c "%root_folder%\cmds\cmd_remove_logs.cmd %current_device%"
)

if "%testing_direct%" == "DL" (
    set "default_ftp_cmd_%current_device%=!default_ftp_dl_cmd:FTP_DL_FILENAME=%dl_filename%!"
) else if "%testing_direct%" == "UL" (
    set "default_ftp_cmd_%current_device%=!default_ftp_ul_cmd:FTP_UL_FILESIZE=%ul_filesize%!"
)
set "default_ftp_cmd_%current_device%=!default_ftp_cmd_%current_device%:FTP_ACCOUNT=%ftp_account%!"
set "default_ftp_cmd_%current_device%=!default_ftp_cmd_%current_device%:FTP_PWD=%ftp_pws%!"
set "default_ftp_cmd_%current_device%=!default_ftp_cmd_%current_device%:SERVER_IP=%server_ip%!"
set "default_ftp_cmd_%current_device%=!default_ftp_cmd_%current_device%:NAMEDEV=%current_device%!"

if "%GENERAL_LOG_GENERATE%" == "True" (
    set "default_ftp_cmd_%current_device%=!default_ftp_cmd_%current_device%:LOG_FILENAME_PRINT=echo $filename >> /xq3_logs_file;!"
    set "default_ftp_cmd_%current_device%=!default_ftp_cmd_%current_device%:LOG_PRINT=| tee /data/xq3/$filename; rm FTP_DL_FILENAME!"
) else (
    set "default_ftp_cmd_%current_device%=!default_ftp_cmd_%current_device%:LOG_FILENAME_PRINT=!"
    set "default_ftp_cmd_%current_device%=!default_ftp_cmd_%current_device%:LOG_PRINT=!"
)

%root_folder%\adb_tool\adb -s %current_device% shell "echo type=ftp > xq3_execute_config"
%root_folder%\adb_tool\adb -s %current_device% shell "echo daemon=%run_daemon% >> xq3_execute_config"
%root_folder%\adb_tool\adb -s %current_device% shell "echo testing_times=%testing_times% >> xq3_execute_config"
%root_folder%\adb_tool\adb -s %current_device% shell "echo stop_once_disconnect=%stop_once_disconnect% >> xq3_execute_config"

%root_folder%\adb_tool\adb -s %current_device% shell "echo '!default_ftp_cmd_%current_device%!' > xq3_execute.sh"

echo %current_device% start testing !!!
if "%OTHERS_WAIT_CMD_FINISH%" == "True" (
    start "%current_device%" /wait cmd /c "%root_folder%\cmds\cmd_start_testing.cmd %current_device% %run_daemon%"
) else (
    start "%current_device%" cmd /c "%root_folder%\cmds\cmd_start_testing.cmd %current_device% %run_daemon%"
)

set /a "index+=1"
if !index! gtr !need_testing_device_num! goto FTP_FOR_LOOP_FOR_RUN_BREAK

goto FTP_FOR_LOOP_FOR_RUN

:FTP_FOR_LOOP_FOR_RUN_BREAK