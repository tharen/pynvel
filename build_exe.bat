REM set path=C:\progs\upx391w;%path%
REM pyinstaller pynvel_runner.py --onefile --name pynvel --console

copy /y pynvel\__main__.py .\run_main.py
pyinstaller pynvel.spec --noconfirm %*
