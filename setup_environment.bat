@ECHO OFF
REM This script searchs for the tools neded to build the C++ template project, e.g. CMake, Visual Studio and Cucumber
REM and further enpacks the dependencies

SET VISUAL_STUDIO="VS2010"
SET PROGRAM_FILES=%PROGRAMFILES(X86)%
IF NOT EXIST "%PROGRAM_FILES%" SET PROGRAM_FILES=%PROGRAMFILES%
SET CMAKE_PATH="%PROGRAM_FILES%"

REM Read arguments
IF "%~1"=="VS2013" (
  SET VISUAL_STUDIO="VS2013"
  IF "%~2"=="--cmake_path" (
    SET CMAKE_PATH="%~3"
  )
)

IF "%~1"=="VS2012" (
  SET VISUAL_STUDIO="VS2012"
  IF "%~2"=="--cmake_path" (
    SET CMAKE_PATH="%~3"
  )
)

IF "%~1"=="--cmake_path" (
  SET CMAKE_PATH="%~2"
  IF "%~3"=="VS2013" (
    SET VISUAL_STUDIO="VS2013"
  ) ELSE IF "%~3"=="VS2012" (
    SET VISUAL_STUDIO="VS2012"
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
) ELSE IF %VISUAL_STUDIO%=="VS2012" (
  SET VISUAL_STUDIO_ENV="%PROGRAM_FILES%\Microsoft Visual Studio 11.0\VC\vcvarsall.bat"
) ELSE (
  SET VISUAL_STUDIO_ENV="%PROGRAM_FILES%\Microsoft Visual Studio 10.0\VC\vcvarsall.bat"
)

IF NOT EXIST %VISUAL_STUDIO_ENV% GOTO visual_studio_missing
CALL %VISUAL_STUDIO_ENV%

REM Enpack the external dependencies, e.g. boost, googlemock, cucumber-cpp, cppspec and igloo headers and libraries
PUSHD externals
@ECHO.
@ECHO ======================================================================================
@ECHO -- Clean up

IF EXIST include DEL /S/Q include
IF EXIST lib DEL /S/Q lib

@ECHO.
@ECHO ======================================================================================
@ECHO -- Unzip external headers and libraries --
@ECHO ------------------------------------------
.\win_externals_include.exe -y

IF %VISUAL_STUDIO%=="VS2013" (
  .\win_externals_lib-msvc12.exe -y
) ELSE IF %VISUAL_STUDIO%=="VS2012" (
  .\win_externals_lib-msvc11.exe -y
) ELSE (
  .\win_externals_lib-msvc10.exe -y
)
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