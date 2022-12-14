@echo off

rem add preferred gpu selector to context menu

::: Setup Environment -------------------------------------------------------------------
set base_reg_key=HKEY_CLASSES_ROOT\*\shell\GpuPref
set base_dir=%programdata%\GpuPref
set base_file=%base_dir%\main.exe

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

del %base_file%
xcopy "%~dp0main.exe" %base_dir% /Y > nul

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