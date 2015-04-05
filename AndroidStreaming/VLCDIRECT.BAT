@ECHO OFF
REM Configuration Script for VLC Direct Pro (https://play.google.com/store/apps/details?id=com.vlcforandroid.vlcdirectprofree)
SETLOCAL ENABLEEXTENSIONS
ECHO ###########################################
ECHO # Configuration Script for VLC Direct Pro #
ECHO ###########################################
ECHO.
<NUL SET /P Dummy=* Finding VLC install location...
ECHO.
SET Key_Name="HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\VLC media player"
IF %processor_architecture% == x86 SET Key_Name=%Key_Name:Wow6432Node\=%
SET Value_Name="InstallLocation"
FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY %Key_Name% /v %Value_Name% 2^>nul`) DO (set VLCPath=%%B)
FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY %Key_Name% /v VersionMajor 2^>nul`) DO (set VersionMajor=%%B)
FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY %Key_Name% /v VersionMinor 2^>nul`) DO (set VersionMinor=%%B)


:ADITIONAL_OPTS
SET OPTS_2_1=
SET OPTS_2=
SET V_2=0
SET V_21=0
IF %VersionMajor% NEQ 2 GOTO AFTER_OPTS_2
	SET OPTS_2= --sout-ffmpeg-strict=-2 --rtsp-timeout=99999 --http-port=8080
	SET V_2=1
	IF %VersionMinor% EQU 0 GOTO AFTER_OPTS_2_1
		SET OPTS_2_1= --http-password=vlcdirect --sout-avcodec-strict=-2
		SET V_21=1
:AFTER_OPTS_2_1
:AFTER_OPTS_2
GOTO AFTER_ADITIONAL_OPTS


:AFTER_ADITIONAL_OPTS
IF %V_21%==1 GOTO RunVLC
SET txtFound=not found!
SET txtPath=If you have VLC installed please
IF "%VLCPath%" == "" GOTO :ManualPath
SET txtFound=found at: %VLCPath%
SET txtPath=Press [Enter] if you want to use VLC installed at this location or
IF EXIST "%VLCPath%\vlcdirect.ok" GOTO :RunVLC
:ManualPath
ECHO %txtFound%
ECHO.
ECHO %txtPath%
SET /P VLCOK=write the path manually and press Enter (i.e. D:\VLC): 
ECHO.
IF "%VLCOK%" NEQ "" SET VLCPath=%VLCOK%
IF EXIST "%VLCPath%\vlc.exe" GOTO :Start
 
:NoVLC
ECHO VLC Player not found. Please install VLC Player from:
ECHO.
ECHO http://www.videolan.org
ECHO.
ECHO Press any key to access the VLC website...
PAUSE >NUL
START http://www.videolan.org
ECHO.
GOTO :END
 
:Start
REM This duplicated condition must stay in case a manual path has been entered
IF EXIST "%VLCPath%\vlcdirect.ok" GOTO :RunVLC
ECHO * Using installation path: %VLCPath%
ECHO.
ECHO * Configuring VLC for VLC Direct Pro, please wait...
IF EXIST "%VLCPath%\vlcdirect.test" DEL /S /Q "%VLCPath%\vlcdirect.test" >NUL 2>&1
<NUL SET /P Dummy=--- Checking administrator access rights...
ECHO Admin access rights test > "%VLCPath%\vlcdirect.test"
IF NOT EXIST "%VLCPath%\vlcdirect.test" GOTO :Access_Problem
ECHO OK.
DEL /S /Q "%VLCPath%\vlcdirect.test" >NUL 2>&1
ECHO --- Configuring hosts files...
SET HostLUA="%VLCPath%\lua\http\.hosts"
SET HostHTTP="%VLCPath%\http\.hosts"
IF EXIST %HostHTTP% GOTO :Mod_Hosts_HTTP
:Step1
IF EXIST %HostLUA% GOTO :Mod_Hosts_Lua_HTTP
:Step2
<NUL SET /P Dummy=--- Checking file:
findstr /m "VLC Direct Pro" %HostFile%
IF NOT "%errorlevel%"=="0" GOTO :Access_Problem
ECHO OK > "%VLCPath%\vlcdirect.ok"
 
ECHO.
ECHO.
ECHO First Time configuration Successful!
ECHO.
ECHO Now in your Android Device, in VLC Direct Pro Free,
ECHO go to Menu, Automatic Connection Wizard and click START
ECHO.
ECHO Enjoy!
ECHO.
SET FirstTime=1
GOTO :RunVLC
 
:Mod_Hosts_HTTP
SET HostFile=%HostHTTP%
SET Return=Step1
GOTO :Hosts
 
:Mod_Hosts_Lua_HTTP
SET HostFile=%HostLua%
SET Return=Step2
 
:Hosts
ECHO. >> %HostFile%
ECHO ### VLC Direct Pro edit starts here ## >> %HostFile%
ECHO 10.0.0.0/8 >> %HostFile%
ECHO 172.16.0.0/12 >> %HostFile%
ECHO 192.168.0.0/16 >> %HostFile%
ECHO 169.254.0.0/16 >> %HostFile%
ECHO ### VLC Direct Pro edit ends here ## >> %HostFile%
GOTO :%Return%
 
:Access_Problem
ECHO.
ECHO.
ECHO This script needs administrator permissions the first time it runs.
ECHO.
ECHO Please Right click on this file (%0) and
ECHO then select "Run as Administrator".
ECHO.
ECHO This is needed only the first time it runs because it needs
ECHO to configure VLC to allow Android connections.
ECHO.
ECHO.
PAUSE
GOTO :END
 
:RunVLC
ECHO.
ECHO.
ECHO * Everything configured.
ECHO * Starting VLC...
START "" "%VLCPath%\vlc.exe" %OPTS_2_1% %OPTS_2% --no-video-title-show --extraintf http
IF "%FirstTime%" == "1" PAUSE
 
:END
