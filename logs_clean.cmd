@echo off
setlocal enabledelayedexpansion

set "root_folder=%~dp0"

call "%root_folder%\cmds\cmd_get_config_value.cmd"
call "%root_folder%\cmds\cmd_wait_adb_all.cmd"

del %root_folder%\tmp\*

REM Run adb devices command and count the number of devices connected
set "device_count=0"
for /f "skip=1 tokens=1" %%a in ('%root_folder%\adb_tool\adb devices ^| findstr /r /b /c:"[0-9A-Za-z]"') do (
    set "device_serial_name=%%a"
    call "%root_folder%\cmds\cmd_remove_logs.cmd""
)

endlocal
pause