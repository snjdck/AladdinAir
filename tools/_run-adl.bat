@echo off

set air-sdk=C:\Program Files\Adobe\Adobe Flash Builder 4.7 (64 Bit)\eclipse\plugins\com.adobe.flash.compiler_4.7.0.349722\AIRSDK
set runtime="%air-sdk%\runtimes\air\win"
set adl="%air-sdk%\bin\adl.exe"

set zip=%cd%\7z.exe
set temp-dir=%cd%\__temp__
set temp-ext-dir=%temp-dir%\ext-dir

set root=E:\test\debug
set ext-dir=E:\test\libs
set app-desc=%root%\MBlock-app.xml

cd /d %ext-dir%
for %%i in (*.ane) do (
	if not exist %temp-ext-dir%\%%i (
		%zip% x -y -o%temp-ext-dir%\%%i %%i
	)
)

cd /d %root%
for %%i in (*.dll) do (
	if not exist %temp-dir%\%%i (
		copy "%%i" "%temp-dir%\%%i"
	)
)

cd /d %temp-dir%

if not exist adl.exe copy %adl% adl.exe
adl -runtime %runtime% -extdir %temp-ext-dir% %app-desc%

::pause