@echo off
:: ============================================================
::  Reset Network Drivers / Network Stack - Windows
::  Run this file as Administrator (Right-click > Run as administrator)
::  What it does:
::    1. Resets Winsock and TCP/IP stack
::    2. Flushes DNS and renews IP address
::    3. Disables + re-enables all network adapters (reloads drivers)
::    4. Restarts DHCP and DNS Client services
::  After it finishes, restart your PC for the changes to fully apply.
:: ============================================================

title Resetting Network Drivers...

:: --- Check for Administrator rights ---
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo  [ERROR] This script needs Administrator rights.
    echo  Right-click this file and choose "Run as administrator".
    echo.
    pause
    exit /b 1
)

echo.
echo  ============================================
echo   Resetting network drivers and stack...
echo  ============================================
echo.

:: --- 1. Reset Winsock (Windows Sockets API) ---
echo  [1/6] Resetting Winsock...
netsh winsock reset
netsh winsock reset catalog

:: --- 2. Reset TCP/IP stack ---
echo.
echo  [2/6] Resetting TCP/IP...
netsh int ip reset
netsh int ipv4 reset
netsh int ipv6 reset

:: --- 3. Reset TCP settings / proxy ---
echo.
echo  [3/6] Resetting TCP and proxy settings...
netsh int tcp reset
netsh winhttp reset proxy

:: --- 4. Disable and re-enable all network adapters ---
::     This forces Windows to unload and reload the network drivers.
echo.
echo  [4/6] Restarting network adapters (reloading drivers)...
echo        Your internet will disconnect briefly - this is normal.
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-NetAdapter | Disable-NetAdapter -Confirm:$false" 2>nul
timeout /t 5 /nobreak >nul
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-NetAdapter | Enable-NetAdapter -Confirm:$false" 2>nul
timeout /t 5 /nobreak >nul

:: --- 5. Flush DNS and renew IP address ---
echo.
echo  [5/6] Flushing DNS and renewing IP address...
ipconfig /release
ipconfig /flushdns
ipconfig /registerdns
ipconfig /renew

:: --- 6. Restart network services ---
echo.
echo  [6/6] Restarting DHCP and DNS Client services...
net stop Dnscache /y >nul 2>&1
net start Dnscache >nul 2>&1
net stop Dhcp /y >nul 2>&1
net start Dhcp >nul 2>&1

echo.
echo  ============================================
echo   Done! Network drivers and stack reset.
echo   Please restart your PC now to finish.
echo  ============================================
echo.

:: --- Optional, aggressive reset (OFF by default) ---
:: Uncomment the line below ONLY if the reset above did not work.
:: It removes ALL network adapters and settings. Windows will
:: reinstall the drivers automatically after a restart.
:: netcfg -d

choice /M "Restart your PC now"
if %errorLevel% equ 1 (
    echo Restarting in 5 seconds...
    shutdown /r /t 5
) else (
    echo.
    echo  OK - remember to restart your PC manually.
    pause
)
