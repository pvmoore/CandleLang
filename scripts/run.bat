@echo off
cls
chcp 65001

if "%1"=="" (
    set PROJECT=_modules\test
) else (
    set PROJECT=_modules\%1
) 

rem cd ..


del /Q _target\build\*.*

if not exist "candle.exe" goto COMPILE
del candle.exe

:COMPILE
dub build --parallel --build=debug --config=test --arch=x86_64 --compiler=dmd


if not exist "candle.exe" goto FAIL
candle.exe %PROJECT%


if not exist "_target\build\test.exe" goto FAIL
call getfilesize.bat _target\build\test.exe
echo.
echo Running _target\build\test.exe (%filesize% bytes)
echo.
_target\build\test.exe
IF %ERRORLEVEL% NEQ 0 (
  echo.
  echo.
  echo Exit code was %ERRORLEVEL%
)
echo.
goto END


:FAIL


:END

echo. 
