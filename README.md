[![Build Status Travis](https://travis-ci.org/meshell/Cpp_project_template.png)](https://travis-ci.org/meshell/Cpp_project_template)
[![Build Status AppVeyor] (https://ci.appveyor.com/api/projects/status/github/meshell/Cpp_project_template?svg=true)
[![Coverage Status](https://coveralls.io/repos/meshell/Cpp_project_template/badge.svg)](https://coveralls.io/r/meshell/Cpp_project_template)

Cpp_project_template
======================

C++ CMake based project template

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
Building the Project requires 
* a recent Version of [CMake](http://www.cmake.org/) (3.2.x). See CMake documentation for more information about building using CMake.
* a recent C++ compiler supporting C++11 (tested on gcc 4.8, 4.9, clang 3.5, 3.6 and Visual Studio 2013 & 2015)

The external dependencies can be downloaded and build using CMake's ExternalProject (make target external_dependencies).

# How to build
--------------

__Linux__
You can run the build.sh script or since cmake is used the normal cmake build workflow can be applied. Just make sure to build the external dependencies first.
E.g.
* mkdir build && (cd build && cmake ..)
* cmake --build build --target external_dependencies --config Debug
* cmake --build build --target all --config Debug

__Windows__
Run the build.bat script to build the project and run the tests or run create_windows_installer.bat to create the installer exe.
Usage:
 build.bat [VS2013|VS2015] [--cmake_path <path_to_cmake>] [--config [Debug|Release]]
 create_windows_installer.bat [VS2013|VS2015] [--cmake_path <path_to_cmake>] [--config [Debug|Release]]


# Running Feature tests
------------------------
See the Cucumber-cpp documentation on how to run the feature tests with cucumber.

# Sonar Metrics
----------------
In order to generate the code metrics and use sonar for publishing the metrics, [sonar-runner](http://docs.codehaus.org/display/SONAR/Installing+and+Configuring+Sonar+Runner), [cppcheck] (http://cppcheck.sourceforge.net/), [valgrind] (http://valgrind.org/) and [Rough Auditing Tool for Security (RATS)] (http://code.google.com/p/rough-auditing-tool-for-security/) are needed. 
On the sonar server the [C++ Community Plugin](http://docs.codehaus.org/pages/viewpage.action?pageId=185073817) should be installed.
