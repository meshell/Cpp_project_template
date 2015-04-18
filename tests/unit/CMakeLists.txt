###################################################
# Create test executables for every testclass
# (no coverage measurement)
###################################################

# Disable some warnings issued by the googletest macro expansions
if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_COMPILER_IS_CLANGCXX)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-global-constructors -Wno-non-virtual-dtor")
endif(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_COMPILER_IS_CLANGCXX)

find_package(GMock REQUIRED)
find_package(GTest REQUIRED)

if(GTEST_FOUND AND GMOCK_FOUND)
  include_directories(SYSTEM
                      ${GTEST_INCLUDE_DIRS}
                      ${GMOCK_INCLUDE_DIRS}
                      )
    
  function(register_test TEST_FILE)
      get_filename_component(TEST_NAME ${TEST_FILE} NAME)
      message(STATUS "Adding " ${TEST_NAME})
      add_executable(${TEST_NAME} ${TEST_FILE}.cpp)
      target_link_libraries(${TEST_NAME} ${GTEST_BOTH_LIBRARIES} ${GMOCK_BOTH_LIBRARIES} ${${PROJECT_NAME}_LIBRARIES} ${ARGN})
      gtest_add_tests(${TEST_NAME} "" ${TEST_FILE}.cpp)
      set(${PROJECT_NAME}_UNITTEST_SOURCES ${${PROJECT_NAME}_UNITTEST_SOURCES} ${TEST_FILE}.cpp PARENT_SCOPE)
  endfunction()

  register_test(src/dummy_test)
endif(GTEST_FOUND AND GMOCK_FOUND)  


###################################################
# Create a single test executable including all testclass.                     
# With coverage measurement
###################################################

set(${PROJECT_NAME}_UNITTEST_NAME 
  unittests
)

if(GTEST_FOUND AND GMOCK_FOUND)
  set(${PROJECT_NAME}_UNITTEST_LIBRARIES 
    ${GTEST_BOTH_LIBRARIES} 
    ${GMOCK_BOTH_LIBRARIES} 
    ${${PROJECT_NAME}_LIBRARIES})
  if(UNIX)
    find_package(Threads) # GTest needs this and it's a static library
    set(${PROJECT_NAME}_UNITTEST_LIBRARIES 
      ${${PROJECT_NAME}_UNITTEST_LIBRARIES} 
      ${CMAKE_THREAD_LIBS_INIT})
  endif(UNIX)  

  add_executable(${${PROJECT_NAME}_UNITTEST_NAME} ${${PROJECT_NAME}_UNITTEST_SOURCES})
  target_link_libraries(${${PROJECT_NAME}_UNITTEST_NAME} ${${PROJECT_NAME}_UNITTEST_LIBRARIES} )

  # Coverage
  if(UNIX AND CMAKE_COMPILER_IS_GNUCXX AND CMAKE_BUILD_TYPE MATCHES Debug)
    include(CodeCoverage)
    set(${PROJECT_NAME}_UNITTEST_LIBRARIES_COVERAGE 
      ${GTEST_BOTH_LIBRARIES}   
      ${GMOCK_BOTH_LIBRARIES} 
      ${${PROJECT_NAME}_LIBRARIES}_coverage)

    add_executable(${${PROJECT_NAME}_UNITTEST_NAME}_coverage  
      EXCLUDE_FROM_ALL 
      ${${PROJECT_NAME}_UNITTEST_SOURCES})
    target_link_libraries(${${PROJECT_NAME}_UNITTEST_NAME}_coverage ${${PROJECT_NAME}_UNITTEST_LIBRARIES_COVERAGE} )

    setup_target_for_coverage_cobertura(coverage_tests 
	${${PROJECT_NAME}_UNITTEST_NAME}_coverage 
        ${COVERAGE_REPORT_DIR}/unittests
        "--gtest_output='xml:${TESTS_REPORT_DIR}/unittests.xml'"
        "-ggcov-${GCC_VERSION}"
    )
  endif(UNIX AND CMAKE_COMPILER_IS_GNUCXX AND CMAKE_BUILD_TYPE MATCHES Debug)
endif(GTEST_FOUND AND GMOCK_FOUND)
