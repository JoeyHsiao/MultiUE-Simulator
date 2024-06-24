:FOR_LOOP_FOR_GET_NOT_TESTING_DEV
set "can_run_devices="
set can_run_devices_num=0
for /f "skip=1 tokens=1" %%a in ('%root_folder%\adb_tool\adb devices ^| findstr /r /b /c:"[0-9A-Za-z]"') do (
    set script_run_or_network_disconnect=0
    for /f "usebackq delims=" %%b in (`%root_folder%\adb_tool\adb -s %%a shell ps ^| findstr xq3_execute`) do (
        set script_run_or_network_disconnect=1
    )

    for /f "usebackq delims=" %%b in (`%root_folder%\adb_tool\adb -s %%a shell cat /var/xq3/net_ifstatus_state`) do (
        if "%%b"=="0" (
            set script_run_or_network_disconnect=1
        )
    )

    if "!script_run_or_network_disconnect!" == "0" (

        if "!can_run_devices_num!" == "0" (
            set "can_run_devices=%%a"
        ) else (
            set "can_run_devices=!can_run_devices! %%a"
        )
        
        set /a "can_run_devices_num+=1"
        if !can_run_devices_num! equ !need_run_device_num! (
            goto BREAK_FOR_LOOP_FOR_GET_NOT_TESTING_DEV
        )
    )
)
goto FOR_LOOP_FOR_GET_NOT_TESTING_DEV

:BREAK_FOR_LOOP_FOR_GET_NOT_TESTING_DEV