@ECHO OFF
@ECHO Create the NSIS installer
SETLOCAL
SET BUILD_DIR=build

CALL setup_environment.bat %*
IF ERRORLEVEL 1 GOTO error

MKDIR %BUILD_DIR%
PUSHD %BUILD_DIR%
@ECHO -- Run cmake --
@ECHO ----------------------
%CMAKE% ..
POPD
IF ERRORLEVEL 1 GOTO error
@ECHO.
@ECHO -- Build external Dependencies --
@ECHO ---------------------------------
%CMAKE% --build %BUILD_DIR% --target externals/external_dependencies
IF ERRORLEVEL 1 GOTO error
@ECHO.
@ECHO -- Build installer --
@ECHO ---------------------------
%CMAKE% --build %BUILD_DIR% --target PACKAGE

IF ERRORLEVEL 1 GOTO error
GOTO end
:error
PAUSE
SET FAILURE_CODE=%ERRORLEVEL%
:end
ENDLOCAL
EXIT /B %FAILURE_CODE%
