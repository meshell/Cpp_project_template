::This script parses the inputfile line by line and replaces a mingw with gcc
:: Use it to fix the project-config.jam file from boost

@echo off &setlocal
set "search=mingw"
set "replace=gcc"
set "textfile=%~1"
set "newfile=tmp.txt"
(for /f "delims=" %%i in (%textfile%) do (
    set "line=%%i"
    setlocal enabledelayedexpansion
    set "line=!line:%search%=%replace%!"
    echo(!line!
    endlocal
))>"%newfile%"
del %textfile%
rename %newfile%  %textfile%