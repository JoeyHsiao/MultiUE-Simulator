@echo off
setlocal enabledelayedexpansion

set "root_folder=%~dp0"

call "%root_folder%\cmds\cmd_get_config_value.cmd"
call "%root_folder%\cmds\cmd_wait_adb_all.cmd"

:WAIT_DEVICES_CONNECT
call "%root_folder%\cmds\cmd_check_network_status.cmd"
if "!connect_network_devices_num!" == "!GENERAL_TOTAL_UE_NUM!" (
    echo All connected
) else (
    cls
    set "count_tmp=0"
    set "devices_state_output="
    for %%i in (!devices_state!) do (
        set /a count_tmp+=1

        if !count_tmp! equ 4 (
            set "devices_state_output=!devices_state_output!"
        ) else if defined devices_state_output (
            set "devices_state_output=!devices_state_output!___(%%i)"
        ) else (
            set "devices_state_output=(%%i)"
        )

        if !count_tmp! equ 4 (
            echo !devices_state_output!
            set "devices_state_output="
            set /a count_tmp=0
        )
    )
    ping -n 3 127.0.0.1 >nul
    goto WAIT_DEVICES_CONNECT
)

endlocal
pause