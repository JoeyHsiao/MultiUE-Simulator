@echo off
setlocal enabledelayedexpansion

set "root_folder=%~dp0"

call "%root_folder%\cmds\cmd_get_config_value.cmd"
call "%root_folder%\cmds\cmd_wait_adb_all.cmd"

REM Run adb devices command and count the number of devices connected
set "device_count=0"
for /f "skip=1 tokens=1" %%a in ('%root_folder%\adb_tool\adb devices ^| findstr /r /b /c:"[0-9A-Za-z]"') do (
    echo %%a

    %root_folder%\adb_tool\adb -s %%a shell "rm /etc/init.d/*xq3* /etc/rc.d/*xq3*  > /dev/null 2>&1"

    %root_folder%\adb_tool\adb -s %%a push scripts\default_apn.json /etc/
    %root_folder%\adb_tool\adb -s %%a shell "sed -i 's/\r//' /etc/default_apn.json"

    %root_folder%\adb_tool\adb -s %%a push scripts\xq3_monitor_daemon /etc/init.d/
    %root_folder%\adb_tool\adb -s %%a shell "sed -i 's/\r//' /etc/init.d/xq3_monitor_daemon"
    %root_folder%\adb_tool\adb -s %%a shell chmod +x /etc/init.d/xq3_monitor_daemon
    %root_folder%\adb_tool\adb -s %%a shell ln -s /etc/init.d/xq3_monitor_daemon /etc/rc.d/S99xq3_monitor_daemon

    %root_folder%\adb_tool\adb -s %%a push scripts\xq3_testing /etc/init.d/
    %root_folder%\adb_tool\adb -s %%a shell "sed -i 's/\r//' /etc/init.d/xq3_testing"
    %root_folder%\adb_tool\adb -s %%a shell chmod +x /etc/init.d/xq3_testing

    %root_folder%\adb_tool\adb -s %%a push scripts\lftp /usr/bin/
    %root_folder%\adb_tool\adb -s %%a shell chmod +x /usr/bin/lftp
    %root_folder%\adb_tool\adb -s %%a push scripts\libreadline.so.8.1 /usr/lib/
    %root_folder%\adb_tool\adb -s %%a shell chmod +x /usr/lib/libreadline.so.8.1
    %root_folder%\adb_tool\adb -s %%a shell ln -s /usr/lib/libreadline.so.8.1  /usr/lib/libreadline.so.8

    %root_folder%\adb_tool\adb -s %%a push scripts\axel_2.17.14 /usr/bin/axel
    %root_folder%\adb_tool\adb -s %%a shell chmod +x /usr/bin/axel
)

echo Finish!!!

endlocal
pause