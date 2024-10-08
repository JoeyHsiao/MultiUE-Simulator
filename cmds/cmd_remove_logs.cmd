set "device_serial_name=%~1"
%root_folder%\adb_tool\adb -s %device_serial_name% shell "rm -rf *xq3* /data/xq3 /data/*xq3* > /dev/null 2>&1"