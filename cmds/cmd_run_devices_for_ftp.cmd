if "!FTP_UE_NUM!"=="" (
    exit /B
) else if "!FTP_UE_NUM!"=="0" (
    exit /B
)
set "need_run_device_num=!FTP_UE_NUM!"

set "default_ftp_dl_cmd=cd /data; rm FTP_DL_FILENAME; TESTING_TIMES; do cur_time=$(date '+%%Y%%m%%d_%%H%%M%%S'); filename=ftp_${cur_time}_NAMEDEV.log; echo $filename >> /xq3_logs_file; lftp -u FTP_ACCOUNT,FTP_PWD SERVER_IP -e "get 'FTP_DL_FILENAME'; quit" | tee /data/$filename; rm FTP_DL_FILENAME; if [ "$(cat /var/xq3/net_ifstatus_state)" = "0" ]; then echo "network_disconnect" >> /xq3_logs_file; break; fi ;done"
set "default_ftp_ul_cmd=cd /data; rm xq3_ftp_ul_NAMEDEV; dd if=/dev/zero of=xq3_ftp_ul_NAMEDEV bs=FTP_UL_FILESIZE count=1; TESTING_TIMES; do cur_time=$(date '+%%Y%%m%%d_%%H%%M%%S'); filename=ftp_${cur_time}_NAMEDEV.log; echo $filename >> /xq3_logs_file; lftp -u FTP_ACCOUNT,FTP_PWD SERVER_IP -e "put 'xq3_ftp_ul_NAMEDEV'; quit" | tee /data/$filename; if [ "$(cat /var/xq3/net_ifstatus_state)" = "0" ]; then echo "network_disconnect" >> /xq3_logs_file; break; fi ;done"
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

if "%testing_times%" == "" (
    set "testing_times=0"
)

echo server_ip=%server_ip%
echo ftp_account=%ftp_account%
echo ftp_pws=%ftp_pws%
echo testing_direct=%testing_direct%
echo dl_filename=%dl_filename%
echo ul_filesize=%ul_filesize%
echo testing_times=%testing_times%
echo run_daemon=%run_daemon%

call "%root_folder%\cmds\cmd_wait_testing_device.cmd
for %%i in (!can_run_devices!) do (
    echo %%i
    echo type=ftp > %root_folder%\tmp\xq3_execute_config_%%i
    echo daemon=%run_daemon% >> %root_folder%\tmp\xq3_execute_config_%%i

    if "%testing_direct%" == "DL" (
        set "default_ftp_cmd_%%i=!default_ftp_dl_cmd:FTP_DL_FILENAME=%dl_filename%!"
    ) else if "%testing_direct%" == "UL" (
        set "default_ftp_cmd_%%i=!default_ftp_ul_cmd:FTP_UL_FILESIZE=%ul_filesize%!"
    )

    set "default_ftp_cmd_%%i=!default_ftp_cmd_%%i:FTP_ACCOUNT=%ftp_account%!"
    set "default_ftp_cmd_%%i=!default_ftp_cmd_%%i:FTP_PWD=%ftp_pws%!"
    set "default_ftp_cmd_%%i=!default_ftp_cmd_%%i:SERVER_IP=%server_ip%!"

    if "%testing_times%" == "0" (
        set "default_ftp_cmd_%%i=!default_ftp_cmd_%%i:TESTING_TIMES=while true!"
    ) else (
        set "default_ftp_cmd_%%i=!default_ftp_cmd_%%i:TESTING_TIMES=for i in $(seq 1 %testing_times%)!"
    )

    set "default_ftp_cmd_%%i=!default_ftp_cmd_%%i:NAMEDEV=%%i!"

    echo !default_ftp_cmd_%%i! > %root_folder%\tmp\xq3_execute_%%i

    if "%OTHERS_WAIT_CMD_FINISH%" == "True" (
        start "%%i" /wait cmd /c "%root_folder%\cmds\cmd_start_testing.cmd %%i"
    ) else (
        start "%%i" cmd /c "%root_folder%\cmds\cmd_start_testing.cmd %%i"
    )
)
