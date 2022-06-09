@ECHO OFF

pushd "%~dp0\.."

REM // make sure we can write to the file sonic3dlc.bin
REM // also make a backup to sonic3dlc.prev.bin
IF NOT EXIST sonic3dlc.bin goto LABLNOCOPY
IF EXIST sonic3dlc.prev.bin del sonic3dlc.prev.bin
IF EXIST sonic3dlc.prev.bin goto LABLNOCOPY
move /Y sonic3dlc.bin sonic3dlc.prev.bin
IF EXIST sonic3dlc.bin goto LABLERROR2

:LABLNOCOPY
REM // delete some intermediate assembler output just in case
IF EXIST sonic3dlc.p del sonic3dlc.p
IF EXIST sonic3dlc.p goto LABLERROR1

REM // clear the output window
REM cls

REM // run the assembler
REM // -xx shows the most detailed error output
REM // -q makes AS shut up
REM // -A gives us a small speedup
set AS_MSGPATH=AS\Win32
set USEANSI=n

REM // allow the user to choose to output error messages to file by supplying the -logerrors parameter
IF "%1"=="-logerrors" ( "AS\Win32\asw.exe" -xx -q -c -D Sonic3_Complete=1 -E -A -L -i "%cd%" sonic3dlc.asm ) ELSE "AS\Win32\asw.exe" -xx -q -c -D Sonic3_Complete=1 -A -L -i "%cd%" sonic3dlc.asm

REM // if there were errors, a log file is produced
IF "%1"=="-logerrors" ( IF EXIST sonic3dlc.log goto LABLERROR3 )

REM // combine the assembler output into a rom
IF EXIST sonic3dlc.p "AS\Win32\fdp2bin" sonic3dlc.p sonic3dlc.bin sonic3dlc.h

REM // done -- pause if we seem to have failed, then exit
IF NOT EXIST sonic3dlc.p goto LABLPAUSE
IF EXIST sonic3dlc.bin goto LABLEXIT

:LABLPAUSE
pause
goto LABLEXIT

:LABLERROR1
echo Failed to build because write access to sonic3dlc.p was denied.
pause
goto LABLEXIT

:LABLERROR2
echo Failed to build because write access to sonic3dlc.bin was denied.
pause
goto LABLEXIT

:LABLERROR3
REM // display a noticeable message
echo.
echo ***************************************************************************
echo *                                                                         *
echo *  There were build errors/warnings. See sonic3dlc.log for more details.  *
echo *                                                                         *
echo ***************************************************************************
echo.
pause

:LABLEXIT
popd
exit /b
