@ECHO OFF
@ECHO Build and run all tests
SETLOCAL
SET BUILD_DIR=build

CALL setup_environment.bat %*

IF ERRORLEVEL 1 GOTO error
@ECHO.
@ECHO ======================================================================================
@ECHO -- Clean up
IF EXIST %BUILD_DIR% DEL /S/Q %BUILD_DIR%
@ECHO ======================================================================================
MKDIR %BUILD_DIR%
PUSHD %BUILD_DIR%
@ECHO.
@ECHO ======================================================================================
@ECHO. 
@ECHO -- Run cmake --
@ECHO ----------------------
IF %VISUAL_STUDIO%=="VS2015" (
  %CMAKE% -G"Visual Studio 14 2015" ..
) ELSE (
  %CMAKE% -G"Visual Studio 12 2013" ..
)
POPD
IF ERRORLEVEL 1 GOTO error
@ECHO.
@ECHO -- Build external Dependencies --
@ECHO ---------------------------------
%CMAKE% --build %BUILD_DIR% --target externals/external_dependencies --config %CONFIG%
IF ERRORLEVEL 1 GOTO error
@ECHO.
@ECHO -- Build everything else --
@ECHO ---------------------------
%CMAKE% --build %BUILD_DIR% --config %CONFIG%
IF ERRORLEVEL 1 GOTO error

@ECHO ======================================================================================
@ECHO. 
@ECHO -- Create Documentation --
@ECHO --------------------------
%CMAKE% --build %BUILD_DIR% --target doc 

GOTO end
:error
PAUSE
SET FAILURE_CODE=%ERRORLEVEL%
:end
ENDLOCAL
EXIT /B %FAILURE_CODE%
