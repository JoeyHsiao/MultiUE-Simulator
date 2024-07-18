@echo off
setlocal enabledelayedexpansion

set "root_folder=%~dp0"

call "%root_folder%\cmds\cmd_get_config_value.cmd"
call "%root_folder%\cmds\cmd_wait_adb_all.cmd"

for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "datestamp=%YYYY%%MM%%DD%" & set "timestamp=%HH%%Min%%Sec%"
set "fullstamp=%YYYY%-%MM%-%DD%_%HH%-%Min%-%Sec%"
set foldername=log_%datestamp%_%timestamp%
echo.
echo --- Log Folder Name: %foldername% ---
echo.
mkdir %foldername%

for /f "skip=1 tokens=1" %%a in ('%root_folder%\adb_tool\adb devices ^| findstr /r /b /c:"[0-9A-Za-z]"') do (
    echo %%a
    
    %root_folder%\adb_tool\adb -s %%a shell /etc/init.d/xq3_testing collect_logs

    for /f "usebackq delims=" %%b in (`%root_folder%\adb_tool\adb -s %%a shell "ls /data/xq3/result_* | xargs -n 1 basename"`) do (
        set "log_name=%%b"
    )
    set "log_name=!log_name:~0,-1!"

    echo !log_name!
    %root_folder%\adb_tool\adb -s %%a pull /data/xq3/!log_name! %foldername%/
    
)

endlocal
pause