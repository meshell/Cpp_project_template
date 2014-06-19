@ECHO OFF
@ECHO Create a Visual Studio solution in vs_build

SET VS_DIR=vs_build

SETLOCAL

CALL setup_environment.bat %*
IF ERRORLEVEL 1 GOTO error

@ECHO.
@ECHO ======================================================================================
@ECHO -- Clean up
IF EXIST %VS_DIR% DEL /S/Q %VS_DIR%
@ECHO ======================================================================================
MKDIR %VS_DIR%
PUSHD %VS_DIR%


IF %VISUAL_STUDIO%=="VS2013" (
  %CMAKE% -G"Visual Studio 12" ..
) ELSE IF %VISUAL_STUDIO%=="VS2012" (
  %CMAKE% -G"Visual Studio 11" ..
) ELSE (
  %CMAKE% -G"Visual Studio 10" ..
)
POPD
GOTO end
:error
PAUSE
SET FAILURE_CODE=%ERRORLEVEL%

:end
ENDLOCAL
EXIT /B %FAILURE_CODE%
