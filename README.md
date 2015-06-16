[![Build Status](https://travis-ci.org/meshell/CMake_project_template.png)](https://travis-ci.org/meshell/CMake_project_template)
[![Coverage Status](https://coveralls.io/repos/meshell/CMake_project_template/badge.svg)](https://coveralls.io/r/meshell/CMake_project_template)

CMake_project_template
======================

C++ CMake project template

An example project which can be used as starting point for C++ projects using cmake. It includes:
* A Dummy [google test] (http://code.google.com/p/googletest/) unit test
* A Dummy BDD Style (Gherkin) feature test using [Cucumber](http://cukes.info/) and [Cucumber-cpp] (https://github.com/cucumber/cucumber-cpp)
* A Dummy BDD Style (Context/Specification) component test using [CppSpec] (https://github.com/tpuronen/cppspec)
* A Dummy BDD Style test using [Igloo] (http://igloo-testing.org/) testing framework
* A Dummy BDD Style test using [Catch] (https://github.com/philsquared/Catch) testing framework
* [SonarQube](http://www.sonarqube.org/) project file
* Makefile to build, run tests and meassure metrics under linux


# Dependencies
---------------
* Building the Project requires a recent Version of [CMake](http://www.cmake.org/) (3.2.x). See CMake documentation for more information about building using CMake.

The external dependencies can be downloaded and build using CMake's ExternalProject (make target external_dependencies).

# How to build
--------------
__Visual Studio 2013__ _(Visual Studio 12)_
* execute the `create_VS_solution.bat` batch file
* if cmake is installed but can not be found, provide the path to the bin folder to the script
  
  Usage: `create_VS_solution.bat --cmake_path <path_to_cmake_root>`
* A visual studio 2013 solution will be placed into folder `vs_build`

__Windows__
* execute the `build.bat` batch file
* if cmake is installed but can not be found, provide the path to the bin folder to the script
  Usage: `build.bat --cmake_path <path_to_cmake_root>`
* The project is built with nmake in folder `build`
* All tests are executed 

__Windows Installer__
* execute the `create_windows_installer.bat` batch file
* if cmake is installed but can not be found, provide the path to the bin folder to the script
  Usage: `create_windows_installer.bat --cmake_path <path_to_cmake_root>`
* The project is built with in folder `build`
* A NSIS installer is created in folder `install`.

__Linux__
Since cmake is used the normal cmake build workflor can be applied. Just make sure to build the external dependencies first.
E.g.
* mkdir build && (cd build && cmake ..)
* cmake --build build --target external_dependencies --config Debug
* cmake --build build --target all --config Debug


# Running Feature tests
------------------------
See the Cucumber-cpp documentation on how to run the feature tests with cucumber.

# Sonar Metrics
----------------
In order to generate the code metrics and use sonar for publishing the metrics, [sonar-runner](http://docs.codehaus.org/display/SONAR/Installing+and+Configuring+Sonar+Runner), [cppcheck] (http://cppcheck.sourceforge.net/), [valgrind] (http://valgrind.org/) and [Rough Auditing Tool for Security (RATS)] (http://code.google.com/p/rough-auditing-tool-for-security/) are needed. 
On the sonar server the [C++ Community Plugin](http://docs.codehaus.org/pages/viewpage.action?pageId=185073817) should be installed.
