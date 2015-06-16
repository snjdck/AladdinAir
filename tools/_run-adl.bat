@echo off

set runtime="C:\Program Files\Adobe\Adobe Flash Builder 4.7 (64 Bit)\eclipse\plugins\com.adobe.flash.compiler_4.7.0.349722\AIRSDK\runtimes\air\win"
set adl="C:\Program Files\Adobe\Adobe Flash Builder 4.7 (64 Bit)\eclipse\plugins\com.adobe.flash.compiler_4.7.0.349722\AIRSDK\bin\adl.exe"
set zip=%cd%\7z.exe

set root=D:\git\debug
set ext-dir=D:\git\libs
set temp-ext-dir=%cd%\__temp__

if not exist __temp__ (md __temp__)

cd /d %ext-dir%

for %%i in (*.ane) do (
	if not exist %temp-ext-dir%\%%i (
		md %temp-ext-dir%\%%i
		%zip% x -y -o%temp-ext-dir%\%%i %%i
	)
)

cd /d %root%

if not exist adl.exe copy %adl% adl.exe
adl -runtime %runtime% MBlock-app.xml -extdir %temp-ext-dir%
del adl.exe

pause