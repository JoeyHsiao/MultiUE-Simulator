REM Run adb devices command and count the number of devices connected
set "device_count=0"
set "device_serial_list="
for /f "skip=1 tokens=1" %%a in ('%root_folder%\adb_tool\adb devices ^| findstr /r /b /c:"[0-9A-Za-z]"') do (
    set /a "device_count+=1"
    set "device_serial_list=!device_serial_list! %%a"
)