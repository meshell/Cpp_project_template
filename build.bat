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
@ECHO -- Build with cmake --
@ECHO ----------------------
%CMAKE% -G "NMake Makefiles" ..
IF ERRORLEVEL 1 GOTO error

nmake
IF ERRORLEVEL 1 GOTO error

@ECHO.
@ECHO ======================================================================================
@ECHO -- Run unittests --
@ECHO -------------------
.\tests\unit\unittests.exe --gtest_shuffle --gtest_output="xml:..\reports\tests\unittests.xml"
@ECHO ======================================================================================
@ECHO.
@ECHO -- Run Spec tests --
@ECHO --------------------
.\tests\spec\specs.exe -m
@ECHO. 
@ECHO -- Generate Spec tests report --
.\tests\spec\specs.exe -m -o junit --report-dir ..\reports\tests
@ECHO ======================================================================================
@ECHO. 
@ECHO -- Run Igloo tests --
@ECHO ---------------------
.\tests\igloo\igloo-tests.exe
@ECHO. 
@ECHO -- Generate Igloo tests report --
.\tests\igloo\igloo-tests.exe --output=xunit > "..\reports\tests\igloo-tests.xml"
@ECHO ======================================================================================
@ECHO. 
@ECHO -- Run Feature tests --
@ECHO -----------------------
start .\tests\feature\features.exe

PUSHD ..\tests\feature
call cucumber -p ci
POPD

POPD
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
