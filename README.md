[![Build Status](https://travis-ci.org/meshell/CMake_project_template.png)](https://travis-ci.org/meshell/CMake_project_template)

CMake_project_template
======================

C++ CMake project template

An example project which can be used as starting point for C++ projects using cmake. It includes:
* A Dummy [google test] (http://code.google.com/p/googletest/) unit test
* A Dummy BDD Style (Gherkin) feature test using [Cucumber](http://cukes.info/) and [Cucumber-cpp] (https://github.com/cucumber/cucumber-cpp)
* A Dummy BDD Style (Context/Specification) component test using [CppSpec] (https://github.com/tpuronen/cppspec)
* A Dummy BDD Style test using [Igloo] (http://igloo-testing.org/) testing framework
* [SonarQube](http://www.sonarqube.org/) project file
* Makefile to build, run tests and meassure metrics under linux


# Dependencies
---------------
* Building the Project requires [CMake](http://www.cmake.org/) Version 2.8. See CMake documentation for more information about building using CMake.

The external dependencies are either
* downloaded and built using CMake's ExternalProject (Linux)
* or provided as selfextracting zip (Windows)

# How to build
--------------
__Visual Studio 2010__ _(Visual Studio 10)_
* execute the `create_VS_solution.bat` batch file
* if cmake is installed but can not be found, provide the path to the bin folder to the script
  Usage: `create_VS_solution.bat --cmake_path <path_to_cmake_root>`
* A visual studio 2010 solution will be placed into folder `vs_build`

__Visual Studio 2012__ _(Visual Studio 11)_
* execute the `create_VS_solution.bat` batch file with VS2012 as batch file argument
* if cmake is installed but can not be found, provide the path to the bin folder to the script
  Usage: `create_VS_solution.bat --cmake_path <path_to_cmake_root>`
* A visual studio 2012 solution will be placed into folder `vs_build`

__Visual Studio 2013__ _(Visual Studio 12)_
* execute the `create_VS_solution.bat` batch file with VS2013 as batch file argument
* if cmake is installed but can not be found, provide the path to the bin folder to the script
  Usage: `create_VS_solution.bat --cmake_path <path_to_cmake_root>`
* A visual studio 2013 solution will be placed into folder `vs_build`
* ___Note:___ Creating a Visual Studio 2013 Solution requires a recent CMake version (> CMake 2.8.11.2)

__Windows__
* execute the `build.bat` batch file (with VS2012 as batch file argument for VS2012)
* if cmake is installed but can not be found, provide the path to the bin folder to the script
  Usage: `build.bat --cmake_path <path_to_cmake_root>`
* The project is built with nmake in folder `build`
* All tests are executed 

__Windows Installer__
* execute the `create_windows_installer.bat` batch file (with VS2012 as batch file argument for VS2012)
* if cmake is installed but can not be found, provide the path to the bin folder to the script
  Usage: `create_windows_installer.bat --cmake_path <path_to_cmake_root>`
* The project is built with in folder `build`
* A NSIS installer is created in folder `install`.

__Linux__
* > make prepare
* make any of the other targets provided (see below)

# Make Targets (Linux)
-----------------------
The following make targets are available
* __all__: Build target test unittests and features
* __clean__: Run cmake target clean and delete the output folder (`build`)
* __prepare__: Download and build all external dependencies (boost, gmock/gtest, CppSpec, cucumber-cpp)
* __main__: Build the main application
* __test__: Build the individual tests and run cmake target test
* __unittest__: Build a single unit test test runner including all unit tests and run it 
* __specs__: Build the CppSpec BDD tests and run it
* __specs-junit__: Build the CppSpec BDD tests and run it with junit (xml) output
* __igloo-tests__: Build the Igloo specificationtest and run it
* __features__: Build the cucumber feature tests and run it
* __wip-features__: Build the cucumber feature tests and run only the WIP features
* __features-doc__: Build the cucumber feature tests and run it producing html output at `reports/tests`
* __coverage__: Build and run all tests with coverage measurement enabled. Generates coverage reports which can be found in `reports/coverage`and JUnit compatible test result reports in `reports/tests`
* __memcheck__: Build and run the feature tests with valgrind. A report is generated in `reports`
* __cppcheck__: Run the cppcheck static code analysis. A report is generated in `reports`
* __rats__: Run the RATS static code analysis. A report is generated in `reports`
* __sonar-runner__: Make target coverage, memcheck, rats and cppcheck and publish the reports on the [SonarQube] (http://www.sonarqube.org/) server
* __doc__: Run doxygen and generate a html documentation in `doc/html`
* __install__: Install target
* __package__: Create a installer with CPack under `install`. (NSIS installer under windows, Debian package under linux)

# Running Feature tests
------------------------
See the Cucumber-cpp documentation on how to run the feature tests with cucumber.

# Sonar Metrics
----------------
In order to generate the code metrics and use sonar for publishing the metrics, [sonar-runner](http://docs.codehaus.org/display/SONAR/Installing+and+Configuring+Sonar+Runner), [cppcheck] (http://cppcheck.sourceforge.net/), [valgrind] (http://valgrind.org/) and [Rough Auditing Tool for Security (RATS)] (http://code.google.com/p/rough-auditing-tool-for-security/) are needed. 
On the sonar server the [C++ Community Plugin](http://docs.codehaus.org/pages/viewpage.action?pageId=185073817) should be installed.
