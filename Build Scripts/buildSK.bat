@ECHO OFF

pushd "%~dp0\.."

REM // make sure we can write to the file sonick.bin
REM // also make a backup to sonick.prev.bin
IF NOT EXIST sonick.bin goto LABLNOCOPY
IF EXIST sonick.prev.bin del sonick.prev.bin
IF EXIST sonick.prev.bin goto LABLNOCOPY
move /Y sonick.bin sonick.prev.bin
IF EXIST sonick.bin goto LABLERROR2

:LABLNOCOPY
REM // delete some intermediate assembler output just in case
IF EXIST sonick.p del sonick.p
IF EXIST sonick.p goto LABLERROR1

REM // clear the output window
REM cls

REM // run the assembler
REM // -xx shows the most detailed error output
REM // -q makes AS shut up
REM // -A gives us a small speedup
set AS_MSGPATH=AS\Win32
set USEANSI=n

REM // allow the user to choose to output error messages to file by supplying the -logerrors parameter
IF "%1"=="-logerrors" ( "AS\Win32\asw.exe" -xx -q -c -D Sonic3_Complete=1 -E -A -L -i "%cd%" sonick.asm ) ELSE "AS\Win32\asw.exe" -xx -q -c -D Sonic3_Complete=1 -A -L -i "%cd%" sonick.asm

REM // if there were errors, a log file is produced
IF "%1"=="-logerrors" ( IF EXIST sonick.log goto LABLERROR3 )

REM // combine the assembler output into a rom
IF EXIST sonick.p "AS\Win32\fdp2bin" sonick.p sonick.bin sonick.h

REM // done -- pause if we seem to have failed, then exit
IF NOT EXIST sonick.p goto LABLPAUSE
IF EXIST sonick.bin goto LABLEXIT

:LABLPAUSE
pause
goto LABLEXIT

:LABLERROR1
echo Failed to build because write access to sonick.p was denied.
pause
goto LABLEXIT

:LABLERROR2
echo Failed to build because write access to sonick.bin was denied.
pause
goto LABLEXIT

:LABLERROR3
REM // display a noticeable message
echo.
echo ***************************************************************************
echo *                                                                         *
echo *   There were build errors/warnings. See sonick.log for more details.    *
echo *                                                                         *
echo ***************************************************************************
echo.
pause

:LABLEXIT
popd
exit /b
