@echo off
setlocal enabledelayedexpansion

set "root_folder=%~dp0"

call "%root_folder%\cmds\cmd_get_config_value.cmd"
call "%root_folder%\cmds\cmd_wait_adb_all.cmd"

set "activity_devices="
for /f "skip=1 tokens=1" %%a in ('%root_folder%\adb_tool\adb devices ^| findstr /r /b /c:"[0-9A-Za-z]"') do (
    set "activity_devices=!activity_devices! %%a"
)

%root_folder%\monitor.exe %root_folder% %activity_devices%
: python monitor.py %root_folder% %activity_devices%

endlocal

pause