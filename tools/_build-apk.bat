@echo off
set adt="C:\Program Files\Adobe\Adobe Flash Builder 4.7 (64 Bit)\eclipse\plugins\com.adobe.flash.compiler_4.7.0.349722\AIRSDK\lib\adt.jar"
set source="bin-release-temp"
cd /d C:\Users\dell\Adobe Flash Builder 4.7\TestApk
java -jar %adt% -package -target apk-captive-runtime -storetype pkcs12 -keystore D:\cert.p12 -storepass 1234 E:\TestApk.apk %source%\TestApk-app.xml -C %source% TestApk.swf
pause