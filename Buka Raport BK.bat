@echo off
chcp 65001 >nul
cd /d "%~dp0"
title Raport BK SMP Muhammadiyah 22
echo.
echo  Raport BK - SMP Muhammadiyah 22 Setiabudi Pamulang
echo  Aplikasi berjalan di komputer ini. Jangan tutup jendela ini.
echo.

where py >nul 2>&1
if %errorlevel%==0 goto :py
where python >nul 2>&1
if %errorlevel%==0 goto :python
goto :ps

:py
start "" cmd /c "timeout /t 1 /nobreak >nul & start http://127.0.0.1:8787/"
py server.py
if errorlevel 1 goto :ps
goto :end

:python
start "" cmd /c "timeout /t 1 /nobreak >nul & start http://127.0.0.1:8787/"
python server.py
if errorlevel 1 goto :ps
goto :end

:ps
echo Python tidak ditemukan. Memakai server Windows...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0server.ps1"
echo.
pause

:end
