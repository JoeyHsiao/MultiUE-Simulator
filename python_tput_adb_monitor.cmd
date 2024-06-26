@echo off
setlocal enabledelayedexpansion

set "root_folder=%~dp0"

call "%root_folder%\cmds\cmd_get_config_value.cmd"
call "%root_folder%\cmds\cmd_wait_adb_all.cmd"

python %root_folder%\cmds\exe_builder\tput_adb_monitor.py %root_folder%

endlocal