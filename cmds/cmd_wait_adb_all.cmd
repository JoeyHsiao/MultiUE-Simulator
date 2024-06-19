:CHECK_DEV_ADB
call "%root_folder%\cmds\cmd_get_adb_devices.cmd"

REM Check if exactly !GENERAL_TOTAL_UE_NUM! devices are connected
if !device_count! equ !GENERAL_TOTAL_UE_NUM! (
    REM do nothing
) else (
    echo Waiting for !GENERAL_TOTAL_UE_NUM! devices to be connected via ADB ^( Current: !device_count! ^)
    ping -n 3 127.0.0.1 >nul
    goto :CHECK_DEV_ADB
)