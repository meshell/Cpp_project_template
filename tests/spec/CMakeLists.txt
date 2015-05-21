#
# Create a single test executable including all testclass.
# With coverage measurement
#


# Disable some warnings issued by the cppspec macro expansions
if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_COMPILER_IS_CLANGCXX)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-exit-time-destructors")
endif(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_COMPILER_IS_CLANGCXX)

set(${PROJECT_NAME}_SPEC_NAME 
  specs
)

set(${PROJECT_NAME}_SPEC_SOURCES
    include/dummy_spec.h
    src/specs.cpp
    src/dummy_spec.cpp
)

set(CORE_BOOST_LIBS regex program_options filesystem date_time chrono thread system)

if(USE_STATIC_BOOST)
  set(Boost_USE_STATIC_LIBS ON)
else(USE_STATIC_BOOST)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DBOOST_ALL_DYN_LINK")
endif(USE_STATIC_BOOST)


find_package(CppSpec REQUIRED)
find_package(Boost COMPONENTS  ${CORE_BOOST_LIBS} REQUIRED)
add_definitions(${Boost_LIB_DIAGNOSTIC_DEFINITIONS})

if(CPPSPEC_FOUND)
  function(register_test TEST_FILE)
      get_filename_component(TEST_NAME ${TEST_FILE} NAME)
      message(STATUS "Adding spec " ${TEST_NAME})
      cppspec_add_tests(${${PROJECT_NAME}_SPEC_NAME} "" ${TEST_FILE}.h)
  endfunction()

  register_test(include/dummy_spec)



  set(${PROJECT_NAME}_SPEC_LIBRARIES 
    ${CPPSPEC_LIBRARIES}
    ${Boost_LIBRARIES}
    ${${PROJECT_NAME}_LIBRARIES})
  include_directories(SYSTEM ${CPPSPEC_INCLUDE_DIR})
  include_directories(include)
  add_executable(${${PROJECT_NAME}_SPEC_NAME} ${${PROJECT_NAME}_SPEC_SOURCES})
  target_link_libraries(${${PROJECT_NAME}_SPEC_NAME} ${${PROJECT_NAME}_SPEC_LIBRARIES} )

  # Coverage
  if(CMAKE_COMPILER_IS_GNUCXX AND CMAKE_BUILD_TYPE MATCHES Debug)
    include(CodeCoverage)
    set(${PROJECT_NAME}_SPEC_LIBRARIES_COVERAGE
      ${CPPSPEC_LIBRARIES}
      ${Boost_LIBRARIES}
      ${${PROJECT_NAME}_LIBRARIES}_coverage)

    add_executable(${${PROJECT_NAME}_SPEC_NAME}_coverage
      EXCLUDE_FROM_ALL
      ${${PROJECT_NAME}_SPEC_SOURCES})
    target_link_libraries(${${PROJECT_NAME}_SPEC_NAME}_coverage ${${PROJECT_NAME}_SPEC_LIBRARIES_COVERAGE} )

    setup_target_for_coverage_cobertura(coverage_specs
      ${${PROJECT_NAME}_SPEC_NAME}_coverage
      ${COVERAGE_REPORT_DIR}/specifications
      "-m;-ojunit;--report-dir;'${TESTS_REPORT_DIR}/'"
      "-ggcov-${GCC_VERSION}"
     )
  endif(CMAKE_COMPILER_IS_GNUCXX AND CMAKE_BUILD_TYPE MATCHES Debug)
endif(CPPSPEC_FOUND) 
