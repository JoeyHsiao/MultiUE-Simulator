set "devices_state="

set connect_network_devices_num=0
set disconnect_network_devices_num=0
REM Run adb devices command and count the number of devices connected
for /f "skip=1 tokens=1" %%a in ('%root_folder%\adb_tool\adb devices ^| findstr /r /b /c:"[0-9A-Za-z]"') do (

    if defined devices_state (
        set "devices_state=!devices_state! %%a"
    ) else (
        set "devices_state=%%a"
    )

    for /f "tokens=*" %%i in ('%root_folder%\adb_tool\adb -s %%a shell "cat /data/xq3/imei"') do (
        set "imei=%%i"
    )

    set "devices_state=!devices_state! !imei!"

    for /f "tokens=*" %%i in ('%root_folder%\adb_tool\adb -s %%a shell "cat /data/xq3/net_md_state"') do (
        set "net_md_state_values=%%i"
    )

    if "0" == "1" (
        set tmp_count=0
        rem Split the string by comma and iterate through each token
        for %%i in (!net_md_state_values!) do (
            set /a tmp_count+=1
            if !tmp_count! equ 2 (
                set "md_register_state_value=%%i"
            )
        )

        if "!md_register_state_value!" == "0" (
            set "devices_state=!devices_state! MT_NOT_SEARCHING"
            set /a "disconnect_network_devices_num+=1"
        ) else if "!md_register_state_value!" == "1" (
            set "device_ifstate="

            for /f "usebackq delims=" %%b in (`%root_folder%\adb_tool\adb -s %%a shell cat /data/xq3/net_ifstatus_state`) do (
                set "device_ifstate=%%b"
            )

            if "!device_ifstate!"=="0" (
                set "devices_state=!devices_state! IFSTATUS_DOWN"
                set /a "disconnect_network_devices_num+=1"
            ) else if "!device_ifstate!"=="1" (
                set "devices_state=!devices_state! IFSTATUS_IP_NOT_GET"
                set /a "connect_network_devices_num+=1"
            ) else (
                set "devices_state=!devices_state! !device_ifstate!"
                set /a "disconnect_network_devices_num+=1"
            )
        ) else if "!md_register_state_value!" == "2" (
            set "devices_state=!devices_state! MT_SEARCHING"
            set /a "disconnect_network_devices_num+=1"
        ) else if "!md_register_state_value!" == "3" (
            set "devices_state=!devices_state! REGISTRATION_DENIED"
            set /a "disconnect_network_devices_num+=1"
        ) else (
            set "devices_state=!devices_state! UNKNOWN"
            set /a "disconnect_network_devices_num+=1"
        )
    )

    for /f "usebackq delims=" %%b in (`%root_folder%\adb_tool\adb -s %%a shell cat /data/xq3/net_ifstatus_state`) do (
        set "device_ifstate=%%b"
    )

    if "!device_ifstate!"=="0" (
        set "devices_state=!devices_state! IFSTATUS_DOWN"
        set /a "disconnect_network_devices_num+=1"
    ) else if "!device_ifstate!"=="1" (
        set "devices_state=!devices_state! IFSTATUS_IP_NOT_GET"
        set /a "connect_network_devices_num+=1"
    ) else (
        set "devices_state=!devices_state! !device_ifstate!"
        set /a "disconnect_network_devices_num+=1"
    )

    set "devices_testing=0"
    for /f "usebackq delims=" %%b in (`%root_folder%\adb_tool\adb -s %%a shell ps ^| findstr xq3_execute`) do (
        set "devices_testing=1"
    )

    if "!devices_testing!"=="0" (
        set "devices_state=!devices_state! stop"
    ) else (
        set "devices_state=!devices_state! testing"
    )

    REM set "devices_state=!devices_state! %%a___(!imsi_without_quotes!)"
)