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

set CLASSPATH="%BASEDIR%"\etc;"%REPO%"\xchange-core-3.1.0.jar;"%REPO%"\Java-WebSocket-1.3.0.jar;"%REPO%"\slf4j-api-1.7.12.jar;"%REPO%"\rescu-1.7.2.jar;"%REPO%"\jackson-databind-2.4.0.jar;"%REPO%"\jackson-annotations-2.4.0.jar;"%REPO%"\jackson-core-2.4.0.jar;"%REPO%"\jsr311-api-1.1.1.jar;"%REPO%"\jsr305-3.0.0.jar;"%REPO%"\base64-2.3.8.jar;"%REPO%"\commons-io-2.4.jar;"%REPO%"\xchange-bitfinex-3.1.0.jar;"%REPO%"\jcommander-1.72.jar;"%REPO%"\influxdb-java-2.7.jar;"%REPO%"\retrofit-2.3.0.jar;"%REPO%"\converter-moshi-2.3.0.jar;"%REPO%"\moshi-1.4.0.jar;"%REPO%"\okhttp-3.8.1.jar;"%REPO%"\okio-1.13.0.jar;"%REPO%"\logging-interceptor-3.8.1.jar;"%REPO%"\org.eclipse.xtend.lib-2.12.0.jar;"%REPO%"\org.eclipse.xtext.xbase.lib-2.12.0.jar;"%REPO%"\guava-19.0-rc3.jar;"%REPO%"\org.eclipse.xtend.lib.macro-2.12.0.jar;"%REPO%"\log4j-api-2.8.2.jar;"%REPO%"\log4j-core-2.8.2.jar;"%REPO%"\log4j-slf4j-impl-2.8.2.jar;"%REPO%"\freyr-0.0.1-SNAPSHOT.jar

set ENDORSED_DIR=
if NOT "%ENDORSED_DIR%" == "" set CLASSPATH="%BASEDIR%"\%ENDORSED_DIR%\*;%CLASSPATH%

if NOT "%CLASSPATH_PREFIX%" == "" set CLASSPATH=%CLASSPATH_PREFIX%;%CLASSPATH%

@REM Reaching here means variables are defined and arguments have been captured
:endInit

%JAVACMD% %JAVA_OPTS%  -classpath %CLASSPATH% -Dapp.name="Freyr-local" -Dapp.repo="%REPO%" -Dapp.home="%BASEDIR%" -Dbasedir="%BASEDIR%" com.sirolf2009.yggdrasil.freyr.Freyr -kafka localhost:9092 %CMD_LINE_ARGS%
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
