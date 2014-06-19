###################################################
# Create test executables for every testclass (no coverage measurement) #
###################################################

find_package(Igloo REQUIRED)

include_directories(${IGLOO_INCLUDE_DIR} ${@PROJECT_NAME@_INCLUDE_DIRS} )
 
set(IGLOO_DIR ${CMAKE_CURRENT_SOURCE_DIR})  
function(register_iglootest TEST_FILE)
  get_filename_component(TEST_NAME ${TEST_FILE} NAME)
  message(STATUS "Adding Igloo test " ${TEST_NAME})
  add_executable(${TEST_NAME} EXCLUDE_FROM_ALL ${TEST_FILE}.cpp ${IGLOO_DIR}/main.cpp)
  link_directories(${@PROJECT_NAME@_LIBRARY_DIRS})
  target_link_libraries(${TEST_NAME} ${@PROJECT_NAME@_LIBRARIES} ${ARGN})
  igloo_add_tests(${TEST_NAME} "" ${TEST_FILE}.cpp)
 endfunction()

# The follwing tests are all the same tests but with different syntax, i.e 
# - Specification/Context
# - Describe It
# - When Then
register_iglootest(dummy_spec)
register_iglootest(dummy_describe)
register_iglootest(dummy_when_then)

############################################
# Create a single test executable including all testclass.           #
# With coverage measurement                                             #
############################################

set(${PROJECT_NAME}_IGLOOTEST_NAME 
  igloo-tests
)

set(@PROJECT_NAME@_IGLOOTEST_SOURCES
  doxtestlistener.h
  dummy_describe.cpp
  main.cpp
)

set(${PROJECT_NAME}_IGLOOTEST_LIBRARIES
     ${@PROJECT_NAME@_LIBRARIES})

include_directories(${@PROJECT_NAME@_INCLUDE_DIRS})
add_executable(${@PROJECT_NAME@_IGLOOTEST_NAME} ${@PROJECT_NAME@_IGLOOTEST_SOURCES})
link_directories(${@PROJECT_NAME@_LIBRARY_DIRS})
target_link_libraries(${@PROJECT_NAME@_IGLOOTEST_NAME} ${@PROJECT_NAME@_IGLOOTEST_LIBRARIES} )

# Coverage
if(CMAKE_COMPILER_IS_GNUCXX AND CMAKE_BUILD_TYPE MATCHES Debug)
  include(CodeCoverage)
  set(${PROJECT_NAME}_IGLOOTEST_LIBRARIES_COVERAGE 
       ${@PROJECT_NAME@_LIBRARIES}_coverage)

  add_executable(${@PROJECT_NAME@_IGLOOTEST_NAME}_coverage  
                          EXCLUDE_FROM_ALL 
                          ${@PROJECT_NAME@_IGLOOTEST_SOURCES})
  target_link_libraries(${@PROJECT_NAME@_IGLOOTEST_NAME}_coverage ${@PROJECT_NAME@_IGLOOTEST_LIBRARIES_COVERAGE} )

  setup_target_for_igloo_coverage_cobertura(coverage_igloo
    ${@PROJECT_NAME@_IGLOOTEST_NAME}_coverage
    ${COVERAGE_REPORT_DIR}/iglootests
    "--output=xunit"
    "${TESTS_REPORT_DIR}/igloo-tests.xml"
    "-ggcov-${GCC_VERSION}"
  )
endif(CMAKE_COMPILER_IS_GNUCXX AND CMAKE_BUILD_TYPE MATCHES Debug)
