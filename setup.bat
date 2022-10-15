@echo off

rem add preferred gpu selector to context menu

::: Setup Environment -------------------------------------------------------------------
set base_reg_key=HKEY_CLASSES_ROOT\*\shell\GpuPref
set base_dir=%programdata%\GpuPref
set base_file=%base_dir%\main.bat

:: Check confiuration
echo. - Verify register entries
REG QUERY "%base_reg_key%" /v "SubCommands">nul && IF %errorlevel% NEQ 0 GOTO _INSTALL
REG QUERY "%base_reg_key%" /v "MUIVerb">nul && IF %errorlevel% NEQ 0 GOTO _INSTALL
rem REG QUERY "%base_reg_key%" /v "Icon">nul && IF %errorlevel% NEQ 0 GOTO _INSTALL

REG QUERY "%base_reg_key%\shell\Integrated" /v "Icon">nul && IF %errorlevel% NEQ 0 GOTO _INSTALL
REG QUERY "%base_reg_key%\shell\Integrated" /v "MUIVerb">nul && IF %errorlevel% NEQ 0 GOTO _INSTALL
REG QUERY "%base_reg_key%\shell\Integrated\command">nul && IF %errorlevel% NEQ 0 GOTO _INSTALL

REG QUERY "%base_reg_key%\shell\Dedicated" /v "Icon">nul && IF %errorlevel% NEQ 0 GOTO _INSTALL
REG QUERY "%base_reg_key%\shell\Dedicated" /v "MUIVerb">nul && IF %errorlevel% NEQ 0 GOTO _INSTALL
REG QUERY "%base_reg_key%\shell\Dedicated\command">nul && IF %errorlevel% NEQ 0 GOTO _INSTALL

echo. - Verify application
IF NOT EXIST %base_dir% CALL mkdir %base_dir%
IF NOT EXIST %base_file% goto _INSTALL missing_main_app

IF "%1" EQU "-f" goto _INSTALL forced_install
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    rem no admin prev
) else ( goto _INSTALL )

GOTO _END

:_INSTALL

:: UAC
echo. - Requesting administrative privileges
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    goto UACPrompt
) else ( goto gotAdmin )
:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B
:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"

echo. - Installing
:: write data
echo. > %base_file%>nul && IF %errorlevel% NEQ 0 GOTO _ERROR unable_write_data

:: setup context menu
reg add "%base_reg_key%" /f /v "SubCommands" /t REG_SZ /d "">nul && IF %errorlevel% NEQ 0 GOTO _ERROR unable_to_add_register_entaries
reg add "%base_reg_key%" /f /v "MUIVerb" /t REG_SZ /d "Run with graphics processor">nul && IF %errorlevel% NEQ 0 GOTO _ERROR unable_to_add_register_entaries
rem reg add "%base_reg_key%" /f /v "Icon" /t REG_SZ /d "\"%~dp0Troid.ico\">nul && IF %errorlevel% NEQ 0 GOTO _ERROR unable_to_add_register_entaries

reg add "%base_reg_key%\shell\Integrated" /f /v "MUIVerb" /t REG_SZ /d "Power Saving">nul && IF %errorlevel% NEQ 0 GOTO _ERROR unable_to_add_register_entaries
reg add "%base_reg_key%\shell\Integrated" /f /v "Icon" /t REG_SZ /d "">nul && IF %errorlevel% NEQ 0 GOTO _ERROR unable_to_add_register_entaries
reg add "%base_reg_key%\shell\Integrated\command" /f /ve /t REG_SZ /d "\"%base_file%\" \"%%1\" \"1\"">nul && IF %errorlevel% NEQ 0 GOTO _ERROR unable_to_add_register_entaries

reg add "%base_reg_key%\shell\Dedicated" /f /v "MUIVerb" /t REG_SZ /d "High Preformance">nul && IF %errorlevel% NEQ 0 GOTO _ERROR unable_to_add_register_entaries
reg add "%base_reg_key%\shell\Dedicated" /f /v "Icon" /t REG_SZ /d "">nul && IF %errorlevel% NEQ 0 GOTO _ERROR unable_to_add_register_entaries
reg add "%base_reg_key%\shell\Dedicated\command" /f /ve /t REG_SZ /d "\"%base_file%\" \"%%1\" \"2\"">nul && IF %errorlevel% NEQ 0 GOTO _ERROR unable_to_add_register_entaries



for /f "useback delims=" %%_ in (%0) do (
  if "%%_"=="___MAIN_END___" set $=
  if defined $ echo(%%_ >> %base_file%
  if "%%_"=="___MAIN_START___" set $=1
)
goto :_END

:_END
echo.
echo. - Operation Success
echo.
pause
goto :eof

:_ERROR
echo.
echo. - Operation Failed
echo. Error : %1
echo.
pause
goto :eof

::: Main Application --------------------------------------------------------------------
___MAIN_START___
@echo off
title GPU Preference Changer - thiwaK
set base_dir=%programdata%\GpuPref
pushd %base_dir%
set app=%1%
set new_preference=%2%
set reg_key=HKCU\Software\Microsoft\DirectX\UserGpuPreferences
set quary_all=reg QUERY %reg_key% /s
set quary_app=reg QUERY %reg_key% /v "%app%"
set app_registered=
set current_preference=
set error="& {Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Unable to modify register. Terminating.', 'Prefered GPU', 'OK', [System.Windows.Forms.MessageBoxIcon]::Error);}"

:: Check if app already registered
for /F "tokens=*" %%i IN ('%quary_all%') DO (
	echo.%%i | find /i "%app%">nul && (
    	set app_registered=%%i
    	goto _CHECK_PREFERENCE
	)
)

:: Set current preference for app already not registered
set current_preference=0
goto _START_APP

:_CHECK_PREFERENCE
:: Get gpu preference
echo.%app_registered% | find /i "GpuPreference=2">nul && (
    REM High Preformence
    set current_preference=2

) || (
    echo.%app_registered% | find /i "GpuPreference=1">nul && (
	    REM Shared
	    set current_preference=1

	) || (
	    REM Windows Decide
	    set current_preference=0
	)
)

:_START_APP
set errorlevel=0
REG ADD "%reg_key%" /v "%app%" /t REG_SZ /d "GpuPreference=%new_preference%" /f > nul
if errorlevel 1 (
  powershell -Command %error% > nul
  exit
)

start /wait "" "%app%"
REG ADD "%reg_key%" /v "%app%" /t REG_SZ /d "GpuPreference=%current_preference%" /f > nul
exit
___MAIN_END___
