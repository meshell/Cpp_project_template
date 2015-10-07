# required minimum version of cmake
cmake_minimum_required(VERSION 3.2 FATAL_ERROR)

# TODO add your test specific header files here
set(CATCH_HEADER_FILES
  ${CMAKE_CURRENT_SOURCE_DIR}/include/googlemock_catch_listener.h
)

source_group("Header Files" FILES ${CATCH_HEADER_FILES})

# set the path to the additional cmake modules
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../../cmake/modules)

# set path to externals
set(CMAKE_INCLUDE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../../externals/include)
set(CMAKE_LIBRARY_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../../externals/lib)

# set report and documentation output paths
set(REPORT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../reports CACHE PATH "Reports directory")
set(COVERAGE_REPORT_DIR ${REPORT_DIR}/coverage CACHE PATH "Coverage reports output directory" )
set(TESTS_REPORT_DIR ${REPORT_DIR}/tests CACHE PATH "Testresult output directory" )

# create report and documentation output directories
file(MAKE_DIRECTORY
  ${REPORT_DIR}
  ${COVERAGE_REPORT_DIR}
  ${TESTS_REPORT_DIR}
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
      ${CMAKE_CURRENT_SOURCE_DIR}/include
  )

  if(GMOCK_FOUND)
    target_include_directories(${TEST_NAME}
      SYSTEM
      PRIVATE
        ${GMOCK_INCLUDE_DIRS}
    )
    target_link_libraries(${TEST_NAME}
      ${GMOCK_LIBRARIES}
    )
  endif(GMOCK_FOUND)

  target_link_libraries(${TEST_NAME}
    internal::projectlib ${ARGN}
  )
  catch_add_tests(${TEST_NAME} "" ${TEST_FILE}.cpp)
  set(CATCHTEST_SOURCES ${CATCHTEST_SOURCES} ${TEST_FILE}.cpp PARENT_SCOPE)
endfunction()

# The following tests are all the same tests but with different syntax, i.e 
# - Classic Test
# - BDD Style Test
register_catchtest(src/dummy_test_catch)
register_catchtest(src/dummy_scenario_catch)
register_catchtest(src/mock_test_catch)

set(CATCHTEST_SOURCES ${CATCHTEST_SOURCES} ${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp)

############################################################
# Create a single test executable including all testclass. #
# Without coverage measurement                             #
############################################################

add_executable(catchtests
  ${CATCHTEST_SOURCES}
  ${CATCH_HEADER_FILES}
)

add_executable(tests::catch ALIAS catchtests)

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
    ${CMAKE_CURRENT_SOURCE_DIR}/include
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
endif(GMOCK_FOUND)

# run allways catch tests target when make all
add_custom_target(run_catchtests
  ALL
    catchtests -s --order rand
)

add_dependencies(run_catchtests
  tests::catch
)

add_custom_target(run_catchtests_junit
  catchtests -r junit;-o ${TESTS_REPORT_DIR}/catch-tests.xml
)

add_dependencies(run_catchtests_junit
  tests::catch
)

####################################################################
# Create and run a single test executable including all testclass. #
# With coverage measurement                                        #
####################################################################
if(UNIX AND CMAKE_COMPILER_IS_GNUCXX AND CMAKE_BUILD_TYPE MATCHES Debug)
    include(CodeCoverage)

    add_executable(catchtests-cov
      EXCLUDE_FROM_ALL
        ${CATCHTEST_SOURCES}
        ${CATCH_HEADER_FILES}
        
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
        ${CMAKE_CURRENT_SOURCE_DIR}/include
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
    )
  endif(GMOCK_FOUND)

  setup_target_for_coverage_cobertura(coverage_catch
    catchtests-cov
    ${COVERAGE_REPORT_DIR}/catchtests
    "-r junit;-o '${TESTS_REPORT_DIR}/catch-tests.xml'"
  )
endif(UNIX AND CMAKE_COMPILER_IS_GNUCXX AND CMAKE_BUILD_TYPE MATCHES Debug)
