@echo off
setlocal enabledelayedexpansion

set "root_folder=%~dp0"

copy %root_folder%\configs\config_NT_1-2-2.ini %root_folder%\_config.ini

call "%root_folder%\cmds\cmd_get_config_value.cmd"
call "%root_folder%\cmds\cmd_wait_adb_all.cmd"

: clean UE logs and tmp files
mkdir %root_folder%\tmp
del /Q %root_folder%\tmp\*
for /f "skip=1 tokens=1" %%a in ('%root_folder%\adb_tool\adb devices ^| findstr /r /b /c:"[0-9A-Za-z]"') do (
    %root_folder%\adb_tool\adb -s %%a shell "rm *xq3* /data/xq3/* > /dev/null 2>&1"
)

echo .
echo http
call "%root_folder%\cmds\cmd_run_devices_for_http.cmd"

REM Wait for 3600 seconds
timeout /t 3600 /nobreak

echo .
echo stop and change to ftp testing 
for /f "skip=1 tokens=1" %%a in ('%root_folder%\adb_tool\adb devices ^| findstr /r /b /c:"[0-9A-Za-z]"') do (
    echo %%a

    %root_folder%\adb_tool\adb -s %%a shell /etc/init.d/xq3_testing stop
    %root_folder%\adb_tool\adb -s %%a shell "killall iperf3 lftp axel curl > /dev/null 2>&1"
)

echo .
echo ftp
call "%root_folder%\cmds\cmd_run_devices_for_ftp.cmd"

REM Wait for 3600 seconds
timeout /t 3600 /nobreak

echo .
echo stop and change to ftp testing 
for /f "skip=1 tokens=1" %%a in ('%root_folder%\adb_tool\adb devices ^| findstr /r /b /c:"[0-9A-Za-z]"') do (
    echo %%a

    %root_folder%\adb_tool\adb -s %%a shell /etc/init.d/xq3_testing stop
    %root_folder%\adb_tool\adb -s %%a shell "killall iperf3 lftp axel curl > /dev/null 2>&1"
)

echo CHT adv NT 1-3-1 finish !!!

endlocal
pause