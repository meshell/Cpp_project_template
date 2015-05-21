#########################################################################
# Create test executables for every testclass (no coverage measurement) #
#########################################################################

find_package(Catch REQUIRED)

include_directories(SYSTEM ${CATCH_INCLUDE_DIR})
 
set(CATCH_DIR ${CMAKE_CURRENT_SOURCE_DIR})  
function(register_catchtest TEST_FILE)
  get_filename_component(TEST_NAME ${TEST_FILE} NAME)
  message(STATUS "Adding Catch test " ${TEST_NAME})
  add_executable(${TEST_NAME} EXCLUDE_FROM_ALL ${TEST_FILE}.cpp ${CATCH_DIR}/main.cpp)
  link_directories(${${PROJECT_NAME}_LIBRARY_DIRS})
  target_link_libraries(${TEST_NAME} ${${PROJECT_NAME}_LIBRARIES} ${ARGN})
  catch_add_tests(${TEST_NAME} "" ${TEST_FILE}.cpp)
 endfunction()

# The following tests are all the same tests but with different syntax, i.e 
# - Classic Test
# - BDD Style Test
register_catchtest(dummy_test_catch)
register_catchtest(dummy_scenario_catch)

############################################################
# Create a single test executable including all testclass. #
# With coverage measurement                                #
############################################################

set(${PROJECT_NAME}_CATCHTEST_NAME 
  catch-tests
)

set(${PROJECT_NAME}_CATCHTEST_SOURCES
  dummy_test_catch.cpp
  dummy_scenario_catch.cpp
  main.cpp
)

set(${PROJECT_NAME}_CATCHTEST_LIBRARIES
     ${${PROJECT_NAME}_LIBRARIES})

add_executable(${${PROJECT_NAME}_CATCHTEST_NAME} ${${PROJECT_NAME}_CATCHTEST_SOURCES})
link_directories(${${PROJECT_NAME}_LIBRARY_DIRS})
target_link_libraries(${${PROJECT_NAME}_CATCHTEST_NAME} ${${PROJECT_NAME}_CATCHTEST_LIBRARIES} )

# Coverage
if(UNIX AND CMAKE_COMPILER_IS_GNUCXX AND CMAKE_BUILD_TYPE MATCHES Debug)
  include(CodeCoverage)
  set(${PROJECT_NAME}_CATCHTEST_LIBRARIES_COVERAGE 
       ${${PROJECT_NAME}_LIBRARIES}_coverage)

  add_executable(${${PROJECT_NAME}_CATCHTEST_NAME}_coverage  
                          EXCLUDE_FROM_ALL 
                          ${${PROJECT_NAME}_CATCHTEST_SOURCES})
  target_link_libraries(${${PROJECT_NAME}_CATCHTEST_NAME}_coverage ${${PROJECT_NAME}_CATCHTEST_LIBRARIES_COVERAGE} )

  setup_target_for_coverage_cobertura(coverage_catch
    ${${PROJECT_NAME}_CATCHTEST_NAME}_coverage
    ${COVERAGE_REPORT_DIR}/catchtests
    "-r junit;-o '${TESTS_REPORT_DIR}/catch-tests.xml'"
    "-ggcov-${GCC_VERSION}"
  )
endif(UNIX AND CMAKE_COMPILER_IS_GNUCXX AND CMAKE_BUILD_TYPE MATCHES Debug)
