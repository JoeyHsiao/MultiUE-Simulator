pyinstaller --onefile monitor.py && move dist\monitor.exe . && rmdir /s /q dist && rmdir /s /q build && del monitor.spec && echo done :) && pause
