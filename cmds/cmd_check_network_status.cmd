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

    for /f "tokens=*" %%i in ('%root_folder%\adb_tool\adb -s %%a shell "cat /var/xq3/imei"') do (
        set "imei=%%i"
    )

    set "devices_state=!devices_state! !imei!"

    for /f "tokens=*" %%i in ('%root_folder%\adb_tool\adb -s %%a shell "cat /var/xq3/net_register_state"') do (
        set "net_register_state_values=%%i"
    )

    if "!net_register_state_values!" == "MIPC_NW_REGISTER_STATE_HOME" (
        for /f "usebackq delims=" %%b in (`%root_folder%\adb_tool\adb -s %%a shell cat /var/xq3/net_ifstatus_state`) do (
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
    ) else (
        set "devices_state=!devices_state! !net_register_state_values!"
        set /a "disconnect_network_devices_num+=1"
    )

    if "0" == "1" (
        for /f "tokens=*" %%i in ('%root_folder%\adb_tool\adb -s %%a shell "cat /var/xq3/net_register_state"') do (
            set "net_register_state_values=%%i"
        )

        set tmp_count=0
        rem Split the string by comma and iterate through each token
        for %%i in (!net_register_state_values!) do (
            set /a tmp_count+=1
            if !tmp_count! equ 2 (
                set "net_register_state_values=%%i"
            )
        )

        if "!net_register_state_values!" == "0" (
            set "devices_state=!devices_state! MT_NOT_SEARCHING"
            set /a "disconnect_network_devices_num+=1"
        ) else if "!net_register_state_values!" == "1" (
            set "device_ifstate="

            for /f "usebackq delims=" %%b in (`%root_folder%\adb_tool\adb -s %%a shell cat /var/xq3/net_ifstatus_state`) do (
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
        ) else if "!net_register_state_values!" == "2" (
            set "devices_state=!devices_state! MT_SEARCHING"
            set /a "disconnect_network_devices_num+=1"
        ) else if "!net_register_state_values!" == "3" (
            set "devices_state=!devices_state! REGISTRATION_DENIED"
            set /a "disconnect_network_devices_num+=1"
        ) else (
            set "devices_state=!devices_state! UNKNOWN"
            set /a "disconnect_network_devices_num+=1"
        )
    )

    if "0" == "1" (
        for /f "usebackq delims=" %%b in (`%root_folder%\adb_tool\adb -s %%a shell cat /var/xq3/net_ifstatus_state`) do (
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
    )

    set "devices_testing=0"
    for /f "usebackq delims=" %%b in (`%root_folder%\adb_tool\adb -s %%a shell "/etc/init.d/xq3_testing status" ^| findstr running`) do (
        set "devices_testing=1"
    )

    if "!devices_testing!"=="0" (
        set "devices_state=!devices_state! stop"
    ) else (
        set "devices_state=!devices_state! testing"
    )

    REM set "devices_state=!devices_state! %%a___(!imsi_without_quotes!)"
)