:FOR_LOOP_FOR_GET_NOT_TESTING_DEV
set "free_devices="
set free_devices_num=0
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

        if "!free_devices_num!" == "0" (
            set "free_devices=%%a"
        ) else (
            set "free_devices=!free_devices! %%a"
        )
        
        set /a "free_devices_num+=1"
        if !free_devices_num! equ !need_testing_device_num! (
            goto BREAK_FOR_LOOP_FOR_GET_NOT_TESTING_DEV
        )
    )
)
goto FOR_LOOP_FOR_GET_NOT_TESTING_DEV

:BREAK_FOR_LOOP_FOR_GET_NOT_TESTING_DEV