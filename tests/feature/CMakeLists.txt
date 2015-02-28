#
# Create a single feature test executable
#

set(${PROJECT_NAME}_BDDTEST_NAME 
  features
)

# Disable some warnings issued by the cucumber-cpp macro expansions
if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_COMPILER_IS_CLANGCXX)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-non-virtual-dtor -Wno-global-constructors")
endif(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_COMPILER_IS_CLANGCXX)

#
# Boost
#
set(CORE_BOOST_LIBS thread system regex date_time chrono)

if(USE_STATIC_BOOST)
  set(Boost_USE_STATIC_LIBS ON)
else(USE_STATIC_BOOST)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DBOOST_ALL_DYN_LINK")
endif(USE_STATIC_BOOST)

find_package(Boost COMPONENTS  ${CORE_BOOST_LIBS} REQUIRED)

#
# CppSpec driver
#
# TODO uncomment next line if cppspec driver should be used
#find_package(CppSpec REQUIRED)

#
# Google Test driver
#
find_package(GTest REQUIRED)

#
# cucumber-cpp
#
find_package(Cuke REQUIRED)

function(register_feature_steps STEP_DEFINITION_FILE)
    get_filename_component(STEP_DEFINITION_FILE_NAME ${STEP_DEFINITION_FILE} NAME)
    message(STATUS "Adding " ${STEP_DEFINITION_FILE})
    # In order to generate step definitions from multiple source files
    # we need to use set CUKE_OBJECT_PREFIX variable for every
    # source file to compile
    # https://github.com/cucumber/cucumber-cpp/issues/36
    string(REPLACE "-" "" OBJ_PREFIX ${STEP_DEFINITION_FILE_NAME})
    set_source_files_properties(${STEP_DEFINITION_FILE}.cpp PROPERTIES COMPILE_FLAGS "-DCUKE_OBJECT_PREFIX=Obj${OBJ_PREFIX}")
    set(STEP_SOURCES ${STEP_SOURCES} ${STEP_DEFINITION_FILE}.cpp PARENT_SCOPE)
endfunction()

if(CUKE_FOUND)
  register_feature_steps(features/step_definition/dummy_steps)
endif(CUKE_FOUND)

# Find all feature files
FILE(GLOB_RECURSE FEATURE_FILES features *.feature)

if(STEP_SOURCES)
  include_directories(SYSTEM 
    ${CUKE_INCLUDE_DIR} 
    ${Boost_INCLUDE_DIRS})

  if (CPPSPEC_FOUND)
    include_directories(SYSTEM ${CPPSPEC_INCLUDE_DIR})  
  endif(CPPSPEC_FOUND)
  
  if (GTEST_FOUND)
    include_directories(SYSTEM ${GTEST_INCLUDE_DIRS})  
  endif(GTEST_FOUND)
  
  
  set(${PROJECT_NAME}_FEATURETEST_LIBRARIES 
    ${@PROJECT_NAME@_LIBRARIES}
    ${CUKE_LIBRARIES} 
    ${Boost_LIBRARIES})    

  if (CPPSPEC_FOUND)
    set(${PROJECT_NAME}_FEATURETEST_LIBRARIES
        ${@PROJECT_NAME@_FEATURETEST_LIBRARIES}
        ${CPPSPEC_LIBRARIES})
  endif(CPPSPEC_FOUND)

  if (GTEST_FOUND)
    set(${PROJECT_NAME}_FEATURETEST_LIBRARIES
        ${@PROJECT_NAME@_FEATURETEST_LIBRARIES}
        ${GTEST_LIBRARIES})
  endif(GTEST_FOUND)

  add_executable(${@PROJECT_NAME@_BDDTEST_NAME} 
    ${STEP_SOURCES}
    ${FEATURE_FILES})
  target_link_libraries(${@PROJECT_NAME@_BDDTEST_NAME} ${@PROJECT_NAME@_FEATURETEST_LIBRARIES})    

  if(NOT MSVC)
    target_link_libraries(${@PROJECT_NAME@_BDDTEST_NAME} pthread rt)
  endif(NOT MSVC)

  if(MSVC)
    set(FEATURE_TEST_EXE_CMD start /B ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/${@PROJECT_NAME@_BDDTEST_NAME}.exe)
  else(MSVC)
    set(FEATURE_TEST_EXE_CMD ${CMAKE_CURRENT_BINARY_DIR}/${@PROJECT_NAME@_BDDTEST_NAME} &)
  endif(MSVC)

 # run feature tests target
  add_custom_target(run_feature_test
    # Run tests
    ${FEATURE_TEST_EXE_CMD}
    COMMAND cucumber --tags ~@wip --no-color -f pretty -s  ${PROJECT_SOURCE_DIR}/tests/feature/features
    COMMENT "Running cucumber."
  )

  add_dependencies(run_feature_test
    ${@PROJECT_NAME@_BDDTEST_NAME}
  )
  
   # run wip features target
  add_custom_target(run_wip_features
    # Run tests
    ${FEATURE_TEST_EXE_CMD}
    COMMAND cucumber --tags @wip --no-color -f pretty -s  ${PROJECT_SOURCE_DIR}/tests/feature/features
    COMMENT "Running cucumber (wip features)."
  )

  add_dependencies(run_wip_features
    ${@PROJECT_NAME@_BDDTEST_NAME}
  )
  
  # Coverage
  if(CMAKE_COMPILER_IS_GNUCXX AND CMAKE_BUILD_TYPE MATCHES Debug)
    include(CodeCoverage)
  
    set(${PROJECT_NAME}_FEATURETEST_LIBRARIES_COVERAGE 
      ${CUKE_LIBRARIES} 
      ${Boost_LIBRARIES}
      ${@PROJECT_NAME@_LIBRARIES}_coverage)  

    if (CPPSPEC_FOUND)
      set(${PROJECT_NAME}_FEATURETEST_LIBRARIES_COVERAGE
          ${@PROJECT_NAME@_FEATURETEST_LIBRARIES_COVERAGE}
          ${CPPSPEC_LIBRARIES})
    endif(CPPSPEC_FOUND)

    if (GTEST_FOUND)
      set(${PROJECT_NAME}_FEATURETEST_LIBRARIES_COVERAGE
          ${@PROJECT_NAME@_FEATURETEST_LIBRARIES_COVERAGE}
          ${GTEST_LIBRARIES})
    endif(GTEST_FOUND)

    add_executable(${@PROJECT_NAME@_BDDTEST_NAME}_coverage  
      EXCLUDE_FROM_ALL 
      ${STEP_SOURCES})
    
    target_link_libraries(${@PROJECT_NAME@_BDDTEST_NAME}_coverage ${@PROJECT_NAME@_FEATURETEST_LIBRARIES_COVERAGE} pthread rt)

    setup_target_under_cucumber_for_coverage_cobertura(
      coverage_features 
      ${@PROJECT_NAME@_BDDTEST_NAME}_coverage
      ${COVERAGE_REPORT_DIR}/features
      ${PROJECT_SOURCE_DIR}/tests/feature/features
      ""
      "-ggcov-${GCC_VERSION}"
    )
  endif(CMAKE_COMPILER_IS_GNUCXX AND CMAKE_BUILD_TYPE MATCHES Debug)
endif(STEP_SOURCES)
