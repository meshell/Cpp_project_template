# C++ Project template main cmake file

# required minimum version of cmake
cmake_minimum_required(VERSION 3.2 FATAL_ERROR)

cmake_policy(SET CMP0048 NEW)

# project name
# TODO fill in your project name and version
project(CMake_project_template VERSION 1.2.0 LANGUAGES CXX C)

# project name used in doxygen docu
STRING(REGEX REPLACE "_" " " PROJECT_DOC_NAME ${PROJECT_NAME})

# project name used for installation
set(APPLICATION_NAME ${PROJECT_DOC_NAME})

if (WIN32)
  # Set a install path in the project folder
  # Windows 7 can not install directly into the default folder (e.g. C:/Program Files (x86)/Cpp_Project_Template)
  set(CMAKE_INSTALL_PREFIX ${PROJECT_SOURCE_DIR}/install CACHE PATH "Install path prefix" FORCE)
endif (WIN32)


# Cmake cache variables
option(BUILD_EXTERNALS "Build also external libraries" TRUE)
option(DISABLE_CPPSPEC "Do not use CppSpec" FALSE)
option(DISABLE_IGLOO "Do not use Igloo testing framework" FALSE)
option(DISABLE_CATCH "Do not use CATCH testing framework" FALSE)


# set default built type to Debug
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Debug)
endif(NOT CMAKE_BUILD_TYPE)

# Cmake test
enable_testing()

#
# Generic Compiler Flags
#

# Check for clang compiler
if(CMAKE_CXX_COMPILER MATCHES ".*clang")
  set(CMAKE_COMPILER_IS_CLANGCXX 1)
endif()

#
# Generic Compiler Flags
#

if(UNIX)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")
endif(UNIX)

# set the path to the additional cmake modules
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules)

# set path to externals
set(CMAKE_INCLUDE_PATH ${PROJECT_SOURCE_DIR}/externals/include)
set(CMAKE_LIBRARY_PATH ${PROJECT_SOURCE_DIR}/externals/lib)

# external libraries
if(BUILD_EXTERNALS)
  add_subdirectory(externals)
endif(BUILD_EXTERNALS)

find_package(Boost)
if(Boost_FOUND)
    add_subdirectory(src)
endif(Boost_FOUND)

# unit tests require gmock
find_package(GMock)

if(GMOCK_FOUND)
    add_subdirectory(tests/unit)
endif(GMOCK_FOUND)

# feature tests require cucumber-cpp (aka cuke)
find_package(Cuke)

if(CUKE_FOUND AND Boost_FOUND)
    add_subdirectory(tests/feature)
endif(CUKE_FOUND AND Boost_FOUND)

# Igloo is used for specifications (BDD style unittests)
# TODO remove the next lines if you dont want to use Igloo
find_package(Igloo)

if(IGLOO_FOUND AND NOT DISABLE_IGLOO)
    add_subdirectory(tests/igloo)
endif(IGLOO_FOUND AND NOT DISABLE_IGLOO)

# Catch is used for BDD style unittests
# TODO remove the next lines if you dont want to use Catch
find_package(Catch)

if(CATCH_FOUND AND NOT DISABLE_CATCH)
    add_subdirectory(tests/catch)
endif(CATCH_FOUND AND NOT DISABLE_CATCH)

# CppSpec is an alternative to Igloo , i.e. used for specifications (BDD style unittests)
# TODO remove the next lines if you dont want to use CppSpec
find_package(CppSpec)

if(CPPSPEC_FOUND AND Boost_FOUND AND NOT DISABLE_CPPSPEC)
    add_subdirectory(tests/spec)
endif(CPPSPEC_FOUND AND Boost_FOUND AND NOT DISABLE_CPPSPEC)


# add a target to generate API documentation with Doxygen
set(DOC_DIR ${PROJECT_SOURCE_DIR}/doc CACHE PATH "Documentation directory")

file(MAKE_DIRECTORY
  ${DOC_DIR}
)

# Doxygen documentation
find_package(Doxygen)
if(DOXYGEN_FOUND)
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/doxygen/Doxyfile.in ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile @ONLY)
    add_custom_target(doc
        ${DOXYGEN_EXECUTABLE} ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile
        WORKING_DIRECTORY ${DOC_DIR}
        COMMENT "Generating API documentation with Doxygen." VERBATIM
    )

    install(DIRECTORY ${DOC_DIR}/html
        DESTINATION doc
        COMPONENT doc
    )
endif(DOXYGEN_FOUND)

install(FILES README.md LICENSE
  DESTINATION doc
  COMPONENT doc
)
  
# Add some custom target
if(UNIX AND CMAKE_COMPILER_IS_GNUCXX AND CMAKE_BUILD_TYPE MATCHES Debug)
	add_custom_target(coverage)
endif(UNIX AND CMAKE_COMPILER_IS_GNUCXX AND CMAKE_BUILD_TYPE MATCHES Debug)

if(TARGET coverage_unittests)
    add_dependencies(coverage coverage_unittests)
endif(TARGET coverage_unittests)

if(TARGET coverage_features)
    add_dependencies(coverage coverage_features)
endif(TARGET coverage_features)

if(TARGET coverage_igloo)
    add_dependencies(coverage coverage_igloo)
endif(TARGET coverage_igloo)

if(TARGET coverage_catch)
    add_dependencies(coverage coverage_catch)
endif(TARGET coverage_catch)

if(TARGET coverage_specs)
    add_dependencies(coverage coverage_specs)
endif(TARGET coverage_specs)

# Targets for code anyalysis
# set report and documentation output paths
set(REPORT_DIR ${PROJECT_SOURCE_DIR}/reports CACHE PATH "Reports directory")

# create report and documentation output directories
file(MAKE_DIRECTORY
    ${REPORT_DIR}
)

find_program(CPPCHECK_EXE cppcheck)

if(CPPCHECK_EXE)
    add_custom_target(run_cppcheck
        ${CPPCHECK_EXE}  -iexternals --enable=style -f --std=c++11 -j2 --xml --suppress=*:externals/include/gtest/gtest.h --suppress=*:externals/include/gtest/internal/gtest-tuple.h --suppress=*:externals/include/gmock/gmock.h ./ 2> ${REPORT_DIR}/cppcheck.xml
        COMMENT "Run cppcheck and output report to ${REPORT_DIR}/cppcheck.xml" VERBATIM
    )
endif(CPPCHECK_EXE)

find_program(RATS_EXE rats)

if(RATS_EXE)
    add_custom_target(run_rats
        ${RATS_EXE}  --quiet --xml ./src > ${REPORT_DIR}/rats.xml
        COMMENT "Run cppcheck and output report to ${REPORT_DIR}/rats.xml" VERBATIM
    )
endif(RATS_EXE)

add_custom_target(clean-reports
    ${CMAKE_COMMAND} -E remove_directory ${REPORT_DIR}
    COMMENT "Delete all reports." VERBATIM
)

add_custom_target(remove_externals
    ${CMAKE_COMMAND} -E remove_directory ${PROJECT_SOURCE_DIR}/externals/include
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${PROJECT_SOURCE_DIR}/externals/lib
    COMMENT "Remove externals (lib & include)." VERBATIM
)

find_program(SONAR_RUNNER_EXE sonar-runner)

if(SONAR_RUNNER_EXE)
    add_custom_target(run_sonar-runner
        ${SONAR_RUNNER_EXE}
        COMMENT "Remove externals (lib & include)." VERBATIM
    )
    add_dependencies(run_sonar-runner clean-reports run_cppcheck run_rats coverage)
endif(SONAR_RUNNER_EXE)


include(CPackConfig.cmake)
