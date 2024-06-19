set "config_file=%root_folder%\_config.ini"

REM Read the config file line by line
for /f "tokens=1,* delims=" %%a in ('type "%config_file%"') do (
    REM Check if line starts with "[" to identify section headers
    if "%%a"=="[General]" (
        set section=GENERAL
    ) else if "%%a"=="[Others]" (
        set section=OTHERS
    ) else if "%%a"=="[Ping]" (
        set section=PING
    ) else if "%%a"=="[FTP]" (
        set section=FTP
    ) else if "%%a"=="[HTTP]" (
        set section=HTTP
    ) else if "%%a"=="[Iperf1]" (
        set section=IPERF1
    ) else if "%%a"=="[Iperf2]" (
        set section=IPERF2
    ) else if "%%a"=="[Iperf3]" (
        set section=IPERF3
    ) else if "%%a"=="[Iperf4]" (
        set section=IPERF4
    ) else (
        REM Store the setting based on the current section
        for /f "tokens=1,* delims==" %%c in ("%%a") do (
            set "setting=%%c"
            set "value=%%d"
            set "!section!_!setting!=!value!"
        )
    )
)