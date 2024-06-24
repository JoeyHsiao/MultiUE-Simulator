@echo off
setlocal enabledelayedexpansion

set "root_folder=%~dp0"

call "%root_folder%\cmds\cmd_get_config_value.cmd"
call "%root_folder%\cmds\cmd_wait_adb_all.cmd"

REM Run adb devices command and count the number of devices connected
set "device_count=0"
for /f "skip=1 tokens=1" %%a in ('%root_folder%\adb_tool\adb devices ^| findstr /r /b /c:"[0-9A-Za-z]"') do (
    echo %%a

    start "%%a" cmd /c "%root_folder%\cmds\cmd_init_device.cmd %%a"
)

echo Wait all devices reboot
call "%root_folder%\cmds\cmd_wait_adb_all.cmd"

endlocal
pause