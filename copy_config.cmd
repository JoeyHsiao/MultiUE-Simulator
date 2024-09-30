@echo off
setlocal enabledelayedexpansion

set "root_folder=%~dp0"

set count=0

for %%f in ("%root_folder%\configs\*") do (
    set /a count+=1
	set "fileList=!fileList!%%f "
	echo !count!. %%~nxf
)

set /p choice=Enter number for file copy: 

set "selectedFile="
set count=0

for %%f in (%fileList%) do (
	set /a count+=1
	if !count! equ %choice% set "selectedFile=%%f"
)

if defined selectedFile (
	echo .
	copy %selectedFile% %root_folder%\_config.ini
) else (
	echo "Error!!"
)

endlocal
pause