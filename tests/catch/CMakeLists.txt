# required minimum version of cmake
cmake_minimum_required(VERSION 3.2 FATAL_ERROR)

# TODO add your test specific header files here
set(CATCH_HEADER_FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/src/googlemock_catch_listener.h
    )

source_group("Header Files" FILES ${CATCH_HEADER_FILES})

# set the path to the additional cmake modules
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../../cmake/modules)

# set path to externals
set(CMAKE_INCLUDE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../../externals/include)
set(CMAKE_LIBRARY_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../../externals/lib)

# set report and documentation output paths
if(NOT REPORT_DIR)
  set(REPORT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../reports CACHE PATH "Reports directory")
endif(NOT REPORT_DIR)
if(NOT COVERAGE_REPORT_DIR)
  set(COVERAGE_REPORT_DIR ${REPORT_DIR}/coverage CACHE PATH "Coverage reports output directory")
endif(NOT COVERAGE_REPORT_DIR)
if(NOT TESTS_REPORT_DIR)
  set(TESTS_REPORT_DIR ${REPORT_DIR}/tests CACHE PATH "Testresult output directory")
endif(NOT TESTS_REPORT_DIR)

# create report and documentation output directories
file(MAKE_DIRECTORY
    ${REPORT_DIR}
    ${COVERAGE_REPORT_DIR}
    ${TESTS_REPORT_DIR}
    )

if(NOT RUNTIME_OUTPUT_DIRECTORY)
  set(RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/../../bin)
endif()

set(TEST_RUNTIME_OUTPUT_DIRECTORY ${RUNTIME_OUTPUT_DIRECTORY}/tests)

file(MAKE_DIRECTORY
    ${RUNTIME_OUTPUT_DIRECTORY}
    ${TEST_RUNTIME_OUTPUT_DIRECTORY}
    )

# Check for clang compiler
if(CMAKE_CXX_COMPILER MATCHES ".*clang")
  set(CMAKE_COMPILER_IS_CLANGCXX 1)
endif()

#########################################################################
# Create test executables for every testclass (no coverage measurement) #
#########################################################################

find_package(Catch REQUIRED)

find_package(GMock)

if(NOT TARGET internal::projectlib)
  include(${CMAKE_CURRENT_SOURCE_DIR}/../../project-export.cmake)
endif()

function(register_catchtest TEST_FILE)
  get_filename_component(TEST_NAME ${TEST_FILE} NAME)
  message(STATUS "Adding Catch test " ${TEST_NAME})
  add_executable(${TEST_NAME}
      ${TEST_FILE}.cpp
      ${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp
      )

  if(CMAKE_COMPILER_IS_CLANGCXX)
    target_compile_options(${TEST_NAME}
        PRIVATE
        -Wno-exit-time-destructors
        )
  endif(CMAKE_COMPILER_IS_CLANGCXX)

  target_include_directories(${TEST_NAME}
      SYSTEM
      PRIVATE
      ${CATCH_INCLUDE_DIRS}
      )

  if(GMOCK_FOUND)
    target_link_libraries(${TEST_NAME}
        GMock::GMock
        GMock::Main
        )

    if(UNIX)
      find_package(Threads) # GTest needs this and it's a static library
      target_link_libraries(${TEST_NAME}
          ${CMAKE_THREAD_LIBS_INIT}
          )
    endif(UNIX)
  endif(GMOCK_FOUND)

  target_link_libraries(${TEST_NAME}
      internal::projectlib ${ARGN}
      )
  catch_add_tests(${TEST_NAME} "" ${TEST_FILE}.cpp)
  set(CATCHTEST_SOURCES ${CATCHTEST_SOURCES} ${TEST_FILE}.cpp PARENT_SCOPE)
endfunction()

# TODO add here all your tests (source file name without extension)
# The following tests are all the same tests but with different syntax, i.e
# - Classic Test
# - BDD Style Test
register_catchtest(src/dummy_test_catch)
register_catchtest(src/dummy_scenario_catch)
register_catchtest(src/mock_test_catch)

set(CATCHTEST_SOURCES ${CATCHTEST_SOURCES} ${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp)

######################################
# Create a single test executable.   #
# Without coverage measurement       #
######################################

add_executable(catchtests
    ${CATCHTEST_SOURCES}
    ${CATCH_HEADER_FILES}
    )

add_executable(tests::catch ALIAS catchtests)

set_target_properties(catchtests
    PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${TEST_RUNTIME_OUTPUT_DIRECTORY}"
    )

if(CMAKE_COMPILER_IS_CLANGCXX)
  target_compile_options(catchtests
      PRIVATE
      -Wno-exit-time-destructors
      )
endif(CMAKE_COMPILER_IS_CLANGCXX)

target_include_directories(catchtests
    SYSTEM
    PRIVATE
    ${CATCH_INCLUDE_DIRS}
    )

target_link_libraries(catchtests
    internal::projectlib
    )

if(GMOCK_FOUND)
  target_include_directories(catchtests
      SYSTEM
      PRIVATE
      ${GMOCK_INCLUDE_DIRS}
      )
  target_link_libraries(catchtests
      ${GMOCK_LIBRARIES}
      )

  if(UNIX)
    find_package(Threads) # GTest needs this and it's a static library
    target_link_libraries(catchtests
        ${CMAKE_THREAD_LIBS_INIT}
        )
  endif(UNIX)
endif(GMOCK_FOUND)


# Target: run catch tests
add_custom_target(run_catchtests
    ALL # run the test always for target all
    catchtests -s --order rand
    )

add_dependencies(run_catchtests
    tests::catch
    )

# Target: run catch tests with junit output
add_custom_target(run_catchtests_junit
    catchtests -r junit;-o ${TESTS_REPORT_DIR}/catch-tests.xml
    )

add_dependencies(run_catchtests_junit
    tests::catch
    )

######################################
# Create a single test executable.   #
# With coverage measurement          #
######################################
if(UNIX AND CMAKE_COMPILER_IS_GNUCXX AND CMAKE_BUILD_TYPE MATCHES Debug)
  include(CodeCoverage)

  add_executable(catchtests-cov
      EXCLUDE_FROM_ALL
      ${CATCHTEST_SOURCES}
      ${CATCH_HEADER_FILES}
      )

  set_target_properties(catchtests-cov
      PROPERTIES
      RUNTIME_OUTPUT_DIRECTORY "${TEST_RUNTIME_OUTPUT_DIRECTORY}"
      )

  if(CMAKE_COMPILER_IS_CLANGCXX)
    target_compile_options(catchtests-cov
        PRIVATE
        -Wno-exit-time-destructors
        )
  endif(CMAKE_COMPILER_IS_CLANGCXX)

  target_include_directories(catchtests-cov
      SYSTEM
      PRIVATE
      ${CATCH_INCLUDE_DIRS}
      )

  target_link_libraries(catchtests-cov
      internal::projectlib-cov
      )

  if(GMOCK_FOUND)
    target_include_directories(catchtests-cov
        SYSTEM
        PRIVATE
        ${GMOCK_INCLUDE_DIRS}
        )
    target_link_libraries(catchtests-cov
        ${GMOCK_LIBRARIES}
        ${CMAKE_THREAD_LIBS_INIT}
        )
  endif(GMOCK_FOUND)

  setup_target_for_coverage_cobertura(coverage_catch
      catchtests-cov
      ${COVERAGE_REPORT_DIR}/catchtests
      "-r junit;-o '${TESTS_REPORT_DIR}/catch-tests.xml'"
      )
endif(UNIX AND CMAKE_COMPILER_IS_GNUCXX AND CMAKE_BUILD_TYPE MATCHES Debug)
