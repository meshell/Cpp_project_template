# required minimum version of cmake
cmake_minimum_required(VERSION 3.2 FATAL_ERROR)

# TODO add your header files here
set(IGLOOTEST_HEADER_FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/src/doxtestlistener.h
)

source_group("Header Files" FILES ${IGLOOTEST_HEADER_FILES})

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
  set(COVERAGE_REPORT_DIR ${REPORT_DIR}/coverage CACHE PATH "Coverage reports output directory" )
endif(NOT COVERAGE_REPORT_DIR)
if(NOT TESTS_REPORT_DIR)
  set(TESTS_REPORT_DIR ${REPORT_DIR}/tests CACHE PATH "Testresult output directory" )
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

find_package(Igloo REQUIRED)

if(NOT TARGET internal::projectlib)
  include(${CMAKE_CURRENT_SOURCE_DIR}/../../project-export.cmake)
endif()

function(register_iglootest TEST_FILE)
  get_filename_component(TEST_NAME ${TEST_FILE} NAME)
  message(STATUS "Adding Igloo test " ${TEST_NAME})
  add_executable(${TEST_NAME}
      ${TEST_FILE}.cpp
      ${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp
  )
  target_include_directories(${TEST_NAME}
      SYSTEM
      PRIVATE
      ${IGLOO_INCLUDE_DIRS}
  )
  target_link_libraries(${TEST_NAME}
      internal::projectlib ${ARGN}
  )
  if(CMAKE_COMPILER_IS_GNUCXX)
    target_compile_options(${TEST_NAME}
        PRIVATE
        -Wno-unused-parameter
    )
  elseif(CMAKE_COMPILER_IS_CLANGCXX)
    target_compile_options(${TEST_NAME}
        PRIVATE
        -Wno-global-constructors
        -Wno-non-virtual-dtor
        -Wno-weak-vtables
    )
  endif(CMAKE_COMPILER_IS_GNUCXX)

  igloo_add_tests(${TEST_NAME} "" ${TEST_FILE}.cpp)
  set(IGLOOTEST_SOURCES ${IGLOOTEST_SOURCES} ${TEST_FILE}.cpp PARENT_SCOPE)
endfunction()

# TODO add here all your tests (source file name without extension)
# The following tests are all the same tests but with different syntax, i.e
# - Specification/Context
# - Describe It
# - When Then
register_iglootest(src/dummy_spec)
register_iglootest(src/dummy_describe)
register_iglootest(src/dummy_when_then)

set(IGLOOTEST_SOURCES ${IGLOOTEST_SOURCES} ${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp)

############################################################
# Create a single test executable including all testclass. #
# Without coverage measurement                             #
############################################################

add_executable(iglootests
    ${IGLOOTEST_SOURCES}
    ${IGLOOTEST_HEADER_FILES}
)

add_executable(tests::igloo ALIAS iglootests)

set_target_properties(iglootests
    PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${TEST_RUNTIME_OUTPUT_DIRECTORY}"
)

target_include_directories(iglootests
    SYSTEM
    PRIVATE
    ${IGLOO_INCLUDE_DIRS}
)

target_link_libraries(iglootests
    internal::projectlib
)

if(CMAKE_COMPILER_IS_GNUCXX)
  target_compile_options(iglootests
      PRIVATE
      -Wno-unused-parameter
  )
elseif(CMAKE_COMPILER_IS_CLANGCXX)
  target_compile_options(iglootests
      PRIVATE
      -Wno-global-constructors
      -Wno-non-virtual-dtor
      -Wno-weak-vtables
  )
endif(CMAKE_COMPILER_IS_GNUCXX)

# Target: run igloo tests
add_custom_target(run_iglootests
    ALL # run the test always for target all
    iglootests
)

add_dependencies(run_iglootests
    tests::igloo
)

# Target: run igloo tests with xunit output
add_custom_target(run_iglootests_xunit
    iglootests --output=xunit > ${TESTS_REPORT_DIR}/igloo-tests.xml
)

add_dependencies(run_iglootests_xunit
    tests::igloo
)

####################################################################
# Create and run a single test executable including all testclass. #
# With coverage measurement                                        #
####################################################################
if(UNIX AND CMAKE_COMPILER_IS_GNUCXX AND CMAKE_BUILD_TYPE MATCHES Debug)
  include(CodeCoverageIgloo)

  add_executable(iglootests-cov
      EXCLUDE_FROM_ALL
      ${IGLOOTEST_SOURCES}
      ${IGLOOTEST_HEADER_FILES}

  )

  set_target_properties(iglootests-cov
      PROPERTIES
      RUNTIME_OUTPUT_DIRECTORY "${TEST_RUNTIME_OUTPUT_DIRECTORY}"
  )

  target_include_directories(iglootests-cov
      SYSTEM
      PRIVATE
      ${IGLOO_INCLUDE_DIRS}
  )

  target_link_libraries(iglootests-cov
      internal::projectlib-cov
  )

  target_compile_options(iglootests-cov
      PRIVATE
      -Wno-unused-parameter
  )

  if(CMAKE_COMPILER_IS_CLANGCXX)
    target_compile_options(iglootests-cov
        PRIVATE
        -Wno-global-constructors
        -Wno-non-virtual-dtor
        -Wno-weak-vtables
    )
  endif(CMAKE_COMPILER_IS_CLANGCXX)

  setup_target_for_igloo_coverage_cobertura(coverage_igloo
      iglootests-cov
      ${COVERAGE_REPORT_DIR}/iglootests
      "--output=xunit"
      "${TESTS_REPORT_DIR}/igloo-tests.xml"
  )
endif(UNIX AND CMAKE_COMPILER_IS_GNUCXX AND CMAKE_BUILD_TYPE MATCHES Debug)
