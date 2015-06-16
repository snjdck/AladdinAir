@echo off
set adt="C:\Program Files\Adobe\Adobe Flash Builder 4.7 (64 Bit)\eclipse\plugins\com.adobe.flash.compiler_4.7.0.349722\AIRSDK\lib\adt.jar"
7z e -y %1 library.swf
java -jar %adt% -package -target ane %~np1.ane extension.xml -swc %1 -platform Windows-x86 library.swf -C windows .
::pause