@echo off
setlocal enabledelayedexpansion

set "root_folder=%~dp0"

call "%root_folder%\cmds\cmd_get_config_value.cmd"
call "%root_folder%\cmds\cmd_wait_adb_all.cmd"

for /f "skip=1 tokens=1" %%a in ('%root_folder%\adb_tool\adb devices ^| findstr /r /b /c:"[0-9A-Za-z]"') do (    
    echo %%a

    set "test_type=xq3_execute_%%a"
    set "test_port=xq3_execute_config_%%a%"
    
    type %root_folder%\tmp\!test_type! | findstr /i "ping_" > nul
    if not errorlevel 1 (
        start "" cmd /c "title %%a-ping && %root_folder%\adb_tool\adb -s %%a shell /etc/init.d/xq3_testing result & pause"
        goto MONITOR_LOOP_CONTINUE
    )

    for /f "usebackq delims=" %%A in ("%root_folder%\tmp\!test_port!") do (
        set device_use_port=%%A
    )

    type %root_folder%\tmp\!test_type! | findstr /i "TCP_DL" > nul && start "" cmd /c "title %%a-TCP-DL-!device_use_port! && %root_folder%\adb_tool\adb -s %%a shell /etc/init.d/xq3_testing result & pause"
    type %root_folder%\tmp\!test_type! | findstr /i "TCP_UL" > nul && start "" cmd /c "title %%a-TCP-UL-!device_use_port! && %root_folder%\adb_tool\adb -s %%a shell /etc/init.d/xq3_testing result & pause"
    type %root_folder%\tmp\!test_type! | findstr /i "UDP_DL" > nul && start "" cmd /c "title %%a-UDP-DL-!device_use_port! && %root_folder%\adb_tool\adb -s %%a shell /etc/init.d/xq3_testing result & pause"
    type %root_folder%\tmp\!test_type! | findstr /i "UDP_UL" > nul && start "" cmd /c "title %%a-UDP-UL-!device_use_port! && %root_folder%\adb_tool\adb -s %%a shell /etc/init.d/xq3_testing result & pause"

:MONITOR_LOOP_CONTINUE
rem Handle continue behavior here
)

endlocal

pause