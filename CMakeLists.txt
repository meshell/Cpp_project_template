# C++ Project template main cmake file

# require minimum version of cmake
cmake_minimum_required(VERSION 2.8)

# project name
# TODO fill in your project name
project(CMake_Project_Template)

# project name used in doxygen docu
STRING(REGEX REPLACE "_" " " PROJECT_DOC_NAME ${PROJECT_NAME})

# project name used for installation
set(APPLICATION_NAME ${PROJECT_DOC_NAME})

if (UNIX)
  string(TOLOWER ${PROJECT_NAME} LOWER_CASE_PROJECT_NAME)
  set(CMAKE_INSTALL_PREFIX /usr/local/${LOWER_CASE_PROJECT_NAME} CACHE PATH "Install path prefix" FORCE)
elseif(UNIX)
  # Set a install path in the project folder
  # Windows 7 can not install directly into the default folder (e.g. C:/Program Files (x86)/Cpp_Project_Template)
  set(CMAKE_INSTALL_PREFIX ${PROJECT_SOURCE_DIR}/install CACHE PATH "Install path prefix" FORCE)
endif (UNIX)


# Cmake cache variables
set(BUILD_EXTERNALS ${UNIX} CACHE BOOL "Build also external libraries")
set(DISABLE_CPPSPEC FALSE CACHE BOOL "Do not use CppSpec")
set(DISABLE_IGLOO FALSE CACHE BOOL "Do not use Igloo testing framework")
set(USE_STATIC_BOOST ${WIN32} CACHE BOOL "Statically link Boost")


# The version number.
set (Project_VERSION_MAJOR 1)
set (Project_VERSION_MINOR 0)
set (Project_VERSION_PATCH 0000)

# configure a header file to pass the version number to the source code

configure_file (
  "${PROJECT_SOURCE_DIR}/project_version.h.in"
  "${CMAKE_CURRENT_SOURCE_DIR}/include/project_version.h"
)

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
# Visual Studio 2012 needs _VARIADIC_MAX preprocessor define set in order to build google test
if (MSVC11)
  add_definitions(/D_VARIADIC_MAX=10)
endif(MSVC11)

if(CMAKE_COMPILER_IS_GNUCXX)
# Determine the gcc version
  execute_process(COMMAND ${CMAKE_CXX_COMPILER} -dumpversion
                          OUTPUT_VARIABLE GCC_VERSION)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread -pedantic -Wall -Wextra -Wcast-align -Wcast-qual -Wctor-dtor-privacy -Wdisabled-optimization -Wformat=2 -Winit-self -Wlogical-op -Wmissing-declarations -Wmissing-include-dirs -Wnoexcept -Wold-style-cast -Woverloaded-virtual -Wredundant-decls -Wshadow -Wsign-conversion -Wsign-promo -Wstrict-null-sentinel -Wstrict-overflow=5 -Wswitch-default -Wundef -Werror")
elseif(CMAKE_COMPILER_IS_CLANGCXX)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread -Weverything -Werror -Wno-c++98-compat -Wno-documentation -Wno-padded -Wno-weak-vtables -Wno-implicit-fallthrough")
endif(CMAKE_COMPILER_IS_GNUCXX)

if(WIN32)
  if(MSVC)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /EHsc /D_WIN32_WINNT=0x0502")
  else(MSVC)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D_WIN32_WINNT=0x0502")
  endif(MSVC)
endif(WIN32)

if(UNIX)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")
endif(UNIX)

# Enable C++11 or C++0x features if possible
include(CheckCXXCompilerFlag)
enable_language(CXX)

check_cxx_compiler_flag("-std=c++11" COMPILER_KNOWS_CXX11)
if(COMPILER_KNOWS_CXX11)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
else(COMPILER_KNOWS_CXX11)
  check_cxx_compiler_flag("-std=c++0x" COMPILER_KNOWS_CXX0X)
  if(COMPILER_KNOWS_CXX0X)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")
  endif(COMPILER_KNOWS_CXX0X)
endif(COMPILER_KNOWS_CXX11)

# set the path to the additional cmake modules
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/modules)

# set report and documentation output paths
set(REPORT_DIR ${CMAKE_SOURCE_DIR}/reports)
set(COVERAGE_REPORT_DIR ${REPORT_DIR}/coverage)
set(TESTS_REPORT_DIR ${REPORT_DIR}/tests)

# create report and documentation output directories
file(MAKE_DIRECTORY
  ${REPORT_DIR}
  ${COVERAGE_REPORT_DIR}
  ${TESTS_REPORT_DIR}
)

# set project include directory
set(${PROJECT_NAME}_INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/include)
include_directories(${${PROJECT_NAME}_INCLUDE_DIRS})

# set path to externals
set(EXTERNALS_INC_DIR ${PROJECT_SOURCE_DIR}/externals/include)
set(EXTERNALS_LIB_DIR ${PROJECT_SOURCE_DIR}/externals/lib)

set(CMAKE_INCLUDE_PATH ${EXTERNALS_INC_DIR} ${CMAKE_INCLUDE_PATH})
set(CMAKE_LIBRARY_PATH ${EXTERNALS_LIB_DIR} ${CMAKE_LIBRARY_PATH})

set(${PROJECT_NAME}_LIBRARY ${PROJECT_NAME}-library)
set(${PROJECT_NAME}_LIBRARIES ${${PROJECT_NAME}_LIBRARY})


# external libraries
if(BUILD_EXTERNALS)
  add_subdirectory(externals)
endif(BUILD_EXTERNALS)

set(SRC_HEADER_FILES ${PROJECT_SOURCE_DIR}/include/dummy.h)

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


# CppSpec is an alternative to Igloo , i.e. used for specifications (BDD style unittests)
# TODO remove the next lines if you dont want to use CppSpec
find_package(CppSpec)

if(CPPSPEC_FOUND AND Boost_FOUND AND NOT DISABLE_CPPSPEC)
  add_subdirectory(tests/spec)
endif(CPPSPEC_FOUND AND Boost_FOUND AND NOT DISABLE_CPPSPEC)


# add a target to generate API documentation with Doxygen
set(DOC_DIR ${CMAKE_SOURCE_DIR}/doc)

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
    COMMENT "Generating API documentation with Doxygen" VERBATIM
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
  
include(CPackConfig.cmake)

