@REM ----------------------------------------------------------------------------
@REM  Copyright 2001-2006 The Apache Software Foundation.
@REM
@REM  Licensed under the Apache License, Version 2.0 (the "License");
@REM  you may not use this file except in compliance with the License.
@REM  You may obtain a copy of the License at
@REM
@REM       http://www.apache.org/licenses/LICENSE-2.0
@REM
@REM  Unless required by applicable law or agreed to in writing, software
@REM  distributed under the License is distributed on an "AS IS" BASIS,
@REM  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
@REM  See the License for the specific language governing permissions and
@REM  limitations under the License.
@REM ----------------------------------------------------------------------------
@REM
@REM   Copyright (c) 2001-2006 The Apache Software Foundation.  All rights
@REM   reserved.

@echo off

set ERROR_CODE=0

:init
@REM Decide how to startup depending on the version of windows

@REM -- Win98ME
if NOT "%OS%"=="Windows_NT" goto Win9xArg

@REM set local scope for the variables with windows NT shell
if "%OS%"=="Windows_NT" @setlocal

@REM -- 4NT shell
if "%eval[2+2]" == "4" goto 4NTArgs

@REM -- Regular WinNT shell
set CMD_LINE_ARGS=%*
goto WinNTGetScriptDir

@REM The 4NT Shell from jp software
:4NTArgs
set CMD_LINE_ARGS=%$
goto WinNTGetScriptDir

:Win9xArg
@REM Slurp the command line arguments.  This loop allows for an unlimited number
@REM of arguments (up to the command line limit, anyway).
set CMD_LINE_ARGS=
:Win9xApp
if %1a==a goto Win9xGetScriptDir
set CMD_LINE_ARGS=%CMD_LINE_ARGS% %1
shift
goto Win9xApp

:Win9xGetScriptDir
set SAVEDIR=%CD%
%0\
cd %0\..\.. 
set BASEDIR=%CD%
cd %SAVEDIR%
set SAVE_DIR=
goto repoSetup

:WinNTGetScriptDir
set BASEDIR=%~dp0\..

:repoSetup
set REPO=


if "%JAVACMD%"=="" set JAVACMD=java

if "%REPO%"=="" set REPO=%BASEDIR%\lib

set CLASSPATH="%BASEDIR%"\etc;"%REPO%"\kafka-clients-0.11.0.0.jar;"%REPO%"\lz4-1.3.0.jar;"%REPO%"\snappy-java-1.1.2.6.jar;"%REPO%"\slf4j-api-1.7.25.jar;"%REPO%"\jcommander-1.72.jar;"%REPO%"\deeplearning4j-core-0.8.0.jar;"%REPO%"\deeplearning4j-modelimport-0.8.0.jar;"%REPO%"\javacpp-1.3.2.jar;"%REPO%"\hdf5-platform-1.10.0-patch1-1.3.jar;"%REPO%"\hdf5-1.10.0-patch1-1.3.jar;"%REPO%"\hdf5-1.10.0-patch1-1.3-linux-x86.jar;"%REPO%"\hdf5-1.10.0-patch1-1.3-linux-x86_64.jar;"%REPO%"\hdf5-1.10.0-patch1-1.3-linux-ppc64le.jar;"%REPO%"\hdf5-1.10.0-patch1-1.3-macosx-x86_64.jar;"%REPO%"\hdf5-1.10.0-patch1-1.3-windows-x86.jar;"%REPO%"\hdf5-1.10.0-patch1-1.3-windows-x86_64.jar;"%REPO%"\deeplearning4j-nn-0.8.0.jar;"%REPO%"\commons-math3-3.4.1.jar;"%REPO%"\commons-io-2.4.jar;"%REPO%"\commons-compress-1.8.jar;"%REPO%"\xz-1.5.jar;"%REPO%"\nd4j-api-0.8.0.jar;"%REPO%"\nd4j-buffer-0.8.0.jar;"%REPO%"\nd4j-context-0.8.0.jar;"%REPO%"\neoitertools-1.0.0.jar;"%REPO%"\commons-lang3-3.3.1.jar;"%REPO%"\jackson-0.8.0.jar;"%REPO%"\snakeyaml-1.12.jar;"%REPO%"\stax2-api-3.1.4.jar;"%REPO%"\joda-time-2.2.jar;"%REPO%"\json-20131018.jar;"%REPO%"\lombok-1.16.10.jar;"%REPO%"\datavec-nd4j-common-0.8.0.jar;"%REPO%"\datavec-api-0.8.0.jar;"%REPO%"\freemarker-2.3.23.jar;"%REPO%"\reflections-0.9.10.jar;"%REPO%"\javassist-3.19.0-GA.jar;"%REPO%"\annotations-2.0.1.jar;"%REPO%"\nd4j-common-0.8.0.jar;"%REPO%"\stream-2.7.0.jar;"%REPO%"\fastutil-6.5.7.jar;"%REPO%"\datavec-data-image-0.8.0.jar;"%REPO%"\jai-imageio-core-1.3.0.jar;"%REPO%"\imageio-jpeg-3.1.1.jar;"%REPO%"\imageio-core-3.1.1.jar;"%REPO%"\imageio-metadata-3.1.1.jar;"%REPO%"\common-lang-3.1.1.jar;"%REPO%"\common-io-3.1.1.jar;"%REPO%"\common-image-3.1.1.jar;"%REPO%"\imageio-tiff-3.1.1.jar;"%REPO%"\imageio-psd-3.1.1.jar;"%REPO%"\imageio-bmp-3.1.1.jar;"%REPO%"\javacv-1.3.1.jar;"%REPO%"\opencv-3.1.0-1.3.jar;"%REPO%"\ffmpeg-3.2.1-1.3.jar;"%REPO%"\flycapture-2.9.3.43-1.3.jar;"%REPO%"\libdc1394-2.2.4-1.3.jar;"%REPO%"\libfreenect-0.5.3-1.3.jar;"%REPO%"\libfreenect2-0.2.0-1.3.jar;"%REPO%"\librealsense-1.9.6-1.3.jar;"%REPO%"\videoinput-0.200-1.3.jar;"%REPO%"\artoolkitplus-2.3.1-1.3.jar;"%REPO%"\flandmark-1.07-1.3.jar;"%REPO%"\opencv-platform-3.1.0-1.3.jar;"%REPO%"\opencv-3.1.0-1.3-android-arm.jar;"%REPO%"\opencv-3.1.0-1.3-android-x86.jar;"%REPO%"\opencv-3.1.0-1.3-linux-x86.jar;"%REPO%"\opencv-3.1.0-1.3-linux-x86_64.jar;"%REPO%"\opencv-3.1.0-1.3-linux-armhf.jar;"%REPO%"\opencv-3.1.0-1.3-linux-ppc64le.jar;"%REPO%"\opencv-3.1.0-1.3-macosx-x86_64.jar;"%REPO%"\opencv-3.1.0-1.3-windows-x86.jar;"%REPO%"\opencv-3.1.0-1.3-windows-x86_64.jar;"%REPO%"\leptonica-platform-1.73-1.3.jar;"%REPO%"\leptonica-1.73-1.3.jar;"%REPO%"\leptonica-1.73-1.3-android-arm.jar;"%REPO%"\leptonica-1.73-1.3-android-x86.jar;"%REPO%"\leptonica-1.73-1.3-linux-x86.jar;"%REPO%"\leptonica-1.73-1.3-linux-x86_64.jar;"%REPO%"\leptonica-1.73-1.3-linux-armhf.jar;"%REPO%"\leptonica-1.73-1.3-linux-ppc64le.jar;"%REPO%"\leptonica-1.73-1.3-macosx-x86_64.jar;"%REPO%"\leptonica-1.73-1.3-windows-x86.jar;"%REPO%"\leptonica-1.73-1.3-windows-x86_64.jar;"%REPO%"\deeplearning4j-ui-components-0.8.0.jar;"%REPO%"\commons-codec-1.10.jar;"%REPO%"\nd4j-native-platform-0.8.0.jar;"%REPO%"\nd4j-native-0.8.0.jar;"%REPO%"\openblas-platform-0.2.19-1.3.jar;"%REPO%"\openblas-0.2.19-1.3.jar;"%REPO%"\openblas-0.2.19-1.3-android-arm.jar;"%REPO%"\openblas-0.2.19-1.3-android-x86.jar;"%REPO%"\openblas-0.2.19-1.3-linux-x86.jar;"%REPO%"\openblas-0.2.19-1.3-linux-x86_64.jar;"%REPO%"\openblas-0.2.19-1.3-linux-armhf.jar;"%REPO%"\openblas-0.2.19-1.3-linux-ppc64le.jar;"%REPO%"\openblas-0.2.19-1.3-macosx-x86_64.jar;"%REPO%"\openblas-0.2.19-1.3-windows-x86.jar;"%REPO%"\openblas-0.2.19-1.3-windows-x86_64.jar;"%REPO%"\nd4j-native-api-0.8.0.jar;"%REPO%"\nd4j-native-0.8.0-android-arm.jar;"%REPO%"\nd4j-native-0.8.0-android-x86.jar;"%REPO%"\nd4j-native-0.8.0-linux-x86_64.jar;"%REPO%"\nd4j-native-0.8.0-macosx-x86_64.jar;"%REPO%"\nd4j-native-0.8.0-windows-x86_64.jar;"%REPO%"\nd4j-native-0.8.0-linux-ppc64le.jar;"%REPO%"\progressbar-0.0.1-SNAPSHOT.jar;"%REPO%"\org.eclipse.xtend.lib-2.12.0.jar;"%REPO%"\org.eclipse.xtext.xbase.lib-2.12.0.jar;"%REPO%"\guava-19.0-rc3.jar;"%REPO%"\org.eclipse.xtend.lib.macro-2.12.0.jar;"%REPO%"\log4j-api-2.8.2.jar;"%REPO%"\log4j-core-2.8.2.jar;"%REPO%"\log4j-slf4j-impl-2.8.2.jar;"%REPO%"\vor-0.0.1-SNAPSHOT.jar

set ENDORSED_DIR=
if NOT "%ENDORSED_DIR%" == "" set CLASSPATH="%BASEDIR%"\%ENDORSED_DIR%\*;%CLASSPATH%

if NOT "%CLASSPATH_PREFIX%" == "" set CLASSPATH=%CLASSPATH_PREFIX%;%CLASSPATH%

@REM Reaching here means variables are defined and arguments have been captured
:endInit

%JAVACMD% %JAVA_OPTS%  -classpath %CLASSPATH% -Dapp.name="data" -Dapp.repo="%REPO%" -Dapp.home="%BASEDIR%" -Dbasedir="%BASEDIR%" com.sirolf2009.yggdrasil.vor.data.Data %CMD_LINE_ARGS%
if %ERRORLEVEL% NEQ 0 goto error
goto end

:error
if "%OS%"=="Windows_NT" @endlocal
set ERROR_CODE=%ERRORLEVEL%

:end
@REM set local scope for the variables with windows NT shell
if "%OS%"=="Windows_NT" goto endNT

@REM For old DOS remove the set variables from ENV - we assume they were not set
@REM before we started - at least we don't leave any baggage around
set CMD_LINE_ARGS=
goto postExec

:endNT
@REM If error code is set to 1 then the endlocal was done already in :error.
if %ERROR_CODE% EQU 0 @endlocal


:postExec

if "%FORCE_EXIT_ON_ERROR%" == "on" (
  if %ERROR_CODE% NEQ 0 exit %ERROR_CODE%
)

exit /B %ERROR_CODE%
