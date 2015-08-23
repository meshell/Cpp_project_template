@ECHO OFF
REM This script searchs for the tools neded to build the C++ template project, e.g. CMake, Visual Studio and Cucumber
REM and further enpacks the dependencies

SET VISUAL_STUDIO="VS2013"
SET CONFIG="Debug"
SET PROGRAM_FILES=%PROGRAMFILES(X86)%
IF NOT EXIST "%PROGRAM_FILES%" SET PROGRAM_FILES=%PROGRAMFILES%
SET CMAKE_PATH="%PROGRAM_FILES%"

REM Read arguments
IF "%~1"=="VS2015" (
  SET VISUAL_STUDIO="VS2015"
  IF "%~2"=="--cmake_path" (
    SET CMAKE_PATH="%~3"
  )
  IF "%~4"=="--cmake_path" (
    SET CMAKE_PATH="%~5"
  )
  IF "%~2"=="--config" (
    SET CONFIG="%~3"
  )
  IF "%~4"=="--config" (
    SET CONFIG="%~5"
  )
)

IF "%~1"=="--cmake_path" (
  SET CMAKE_PATH="%~2"
  IF "%~3"=="VS2015" (
    SET VISUAL_STUDIO="VS2015"
  )
  IF "%~5"=="VS2015" (
    SET VISUAL_STUDIO="VS2015"
  )
  IF "%~3"=="--config" (
    SET CONFIG="%~4"
  )
  IF "%~4"=="--config" (
    SET CONFIG="%~5"
  )
)

IF "%~1"=="--config" (
  SET CONFIG="%~2"
  IF "%~3"=="VS2015" (
    SET VISUAL_STUDIO="VS2015"
  )
  IF "%~5"=="VS2015" (
    SET VISUAL_STUDIO="VS2015"
  )
  IF "%~3"=="--cmake_path" (
    SET CMAKE_PATH="%~4"
  )
  IF "%~4"=="--cmake_path" (
    SET CMAKE_PATH="%~5"
  )
)

REM Search cmake
IF NOT EXIST %CMAKE_PATH% GOTO cmake_path_error
PUSHD %CMAKE_PATH%

FOR /f "delims=" %%A IN ('dir /b /s cmake.exe') DO SET F=%%A
IF EXIST "%F%" (
  SET CMAKE="%F%"
) ELSE (
  GOTO cmake_missing
)
POPD

REM Search for Visual studio and set the environment for using MS Visual Studio tools
IF %VISUAL_STUDIO%=="VS2013" (
  SET VISUAL_STUDIO_ENV="%PROGRAM_FILES%\Microsoft Visual Studio 12.0\VC\vcvarsall.bat"
) ELSE IF %VISUAL_STUDIO%=="VS2015" (
  SET VISUAL_STUDIO_ENV="%PROGRAM_FILES%\Microsoft Visual Studio 14.0\VC\vcvarsall.bat"
)

IF NOT EXIST %VISUAL_STUDIO_ENV% GOTO visual_studio_missing
@ECHO CALL %VISUAL_STUDIO_ENV%
CALL %VISUAL_STUDIO_ENV%

PUSHD externals
@ECHO.
@ECHO ======================================================================================
@ECHO -- Clean up externals

IF EXIST include DEL /S/Q include
IF EXIST lib DEL /S/Q lib

@ECHO.
POPD

GOTO end

:cmake_path_error
@ECHO Path to cmake does not exist.
SET FAILURE_CODE=1
GOTO :end

:cmake_missing
@ECHO Error: Could not find cmake. Please provide the path to cmake.
@ECHO Usage: configure.bat --cmake_path [path to cmake.exe]
SET FAILURE_CODE=1
GOTO :end
:visual_studio_missing
ECHO Error: Could not find Visual Studio (%VISUAL_STUDIO%).
SET FAILURE_CODE=1
GOTO :end
:end
IF ERRORLEVEL 1 SET FAILURE_CODE=%ERRORLEVEL%
EXIT /B %FAILURE_CODE%