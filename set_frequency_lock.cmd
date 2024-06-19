@echo off
setlocal enabledelayedexpansion

set "root_folder=%~dp0"

call "%root_folder%\cmds\cmd_get_config_value.cmd"
call "%root_folder%\cmds\cmd_wait_adb_all.cmd"

REM Run adb devices command and count the number of devices connected
set "device_count=0"
for /f "skip=1 tokens=1" %%a in ('%root_folder%\adb_tool\adb devices ^| findstr /r /b /c:"[0-9A-Za-z]"') do (
    echo %%a

    if "%GENERAL_BAND%" == "n78" (
        %root_folder%\adb_tool\adb -s %%a shell "mipc_wan_cli2 --at_cmd AT+EPBSEH=,,,\\\"00000000000000000000200000000000\\\""
    ) else if "%GENERAL_BAND%" == "n79" (
        %root_folder%\adb_tool\adb -s %%a shell "mipc_wan_cli2 --at_cmd AT+EPBSEH=,,,\\\"0000000000000000000040000000000000\\\""
    )

    if "%GENERAL_NARFCN%" == "" (
        %root_folder%\adb_tool\adb -s %%a shell "mipc_wan_cli2 --at_cmd at+emmchlck=0"
    ) else if "%GENERAL_PCI%" == "" (
        %root_folder%\adb_tool\adb -s %%a shell "mipc_wan_cli2 --at_cmd at+emmchlck=0"
    ) else (
        %root_folder%\adb_tool\adb -s %%a shell "mipc_wan_cli2 --at_cmd at+emmchlck=1,11,0,%GENERAL_NARFCN%,%GENERAL_PCI%"
    )
)

echo Finish!!!

endlocal
pause