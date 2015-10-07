# required minimum version of cmake
cmake_minimum_required(VERSION 3.2 FATAL_ERROR)

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

set(DOC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../doc CACHE PATH "Documentation directory")

file(MAKE_DIRECTORY
  ${DOC_DIR}
)

option(USE_STATIC_BOOST "Statically link Boost" ${WIN32})

if(NOT TARGET internal::projectlib)
  include(${CMAKE_CURRENT_SOURCE_DIR}/../../project-export.cmake)
endif()

# Check for clang compiler
if(CMAKE_CXX_COMPILER MATCHES ".*clang")
  set(CMAKE_COMPILER_IS_CLANGCXX 1)
endif()

############################################
# Create a single feature test executable. #
# Without coverage measurement             #
############################################

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
  register_feature_steps(features/step_definitions/dummy_steps)
  register_feature_steps(features/step_definitions/mock_steps)
endif(CUKE_FOUND)

#
# Boost
#
set(CORE_BOOST_LIBS thread system regex date_time chrono)

if(USE_STATIC_BOOST)
  set(Boost_USE_STATIC_LIBS ON)
else(USE_STATIC_BOOST)
  target_compile_definitions(${PROJECT_NAME}
  PRIVATE
    BOOST_ALL_DYN_LINK
  )
endif(USE_STATIC_BOOST)

find_package(Boost COMPONENTS  ${CORE_BOOST_LIBS} REQUIRED)

#
# CppSpec driver
#
# TODO uncomment next line if cppspec driver should be used
find_package(CppSpec)

#
# Google Test driver
#
find_package(GTest REQUIRED)

#
# For using Googe Mock
#
find_package(GMock)

# Find all feature files
FILE(GLOB_RECURSE FEATURE_FILES features *.feature)

source_group("Feature Files" FILES ${FEATURE_FILES})

if(STEP_SOURCES)
  add_executable(features
    ${STEP_SOURCES}
    ${FEATURE_FILES}
  )

  add_executable(tests::features ALIAS features)

  target_link_libraries(features
    ${CUKE_LIBRARIES}
    ${Boost_LIBRARIES}
    internal::projectlib
  )

  if(CMAKE_COMPILER_IS_CLANGCXX)
    target_compile_options(features
      PRIVATE
        -Wno-non-virtual-dtor
        -Wno-global-constructors
    )
  endif(CMAKE_COMPILER_IS_CLANGCXX)

  if(CPPSPEC_FOUND)
    target_include_directories(features
      SYSTEM
      PRIVATE
        ${CPPSPEC_INCLUDE_DIRS}
    )
    target_link_libraries(features
      ${CPPSPEC_LIBRARIES}
    )
  endif(CPPSPEC_FOUND)

  if(GTEST_FOUND)
    target_include_directories(features
      SYSTEM
      PRIVATE
        ${GTEST_INCLUDE_DIRS}
    )
    target_link_libraries(features
      ${GTEST_LIBRARIES}
    )
  endif(GTEST_FOUND)

  if(GMOCK_FOUND)
    target_include_directories(features
      SYSTEM
      PRIVATE
        ${GMOCK_INCLUDE_DIRS}
    )
    target_link_libraries(features
      ${GMOCK_LIBRARIES}
    )
  endif(GMOCK_FOUND)

  if(NOT MSVC)
    find_library(PTREAD_LIB pthread REQUIRED)
    target_link_libraries(features
      ${PTREAD_LIB}
    )
  endif(NOT MSVC)

  if(WIN32)
    find_library(WS2_LIB ws2_32)
    target_link_libraries(features
      ${WS2_LIB}
    )
  else(WIN32)
    find_library(RT_LIB rt)
    target_link_libraries(features
      ${RT_LIB}
    )
  endif(WIN32)

  if(WIN32)
    if(MSVC)
      set(FEATURE_TEST_EXE_CMD start /B ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/features.exe)
    else(MSVC)
      set(FEATURE_TEST_EXE_CMD start /B ${CMAKE_CURRENT_BINARY_DIR}/features.exe)
    endif(MSVC)
  else(WIN32)
    set(FEATURE_TEST_EXE_CMD ${CMAKE_CURRENT_BINARY_DIR}/features &)
  endif(WIN32)

  # run feature tests target
  add_custom_target(run_feature_test
    # Run tests
    ${FEATURE_TEST_EXE_CMD}
    COMMAND cucumber --tags ~@wip --tags ~@proposal --no-color -f pretty -s ${CMAKE_CURRENT_SOURCE_DIR}/features
    COMMENT "Running cucumber."
  )

  add_dependencies(run_feature_test
    tests::features
  )

  # run wip features target
  add_custom_target(run_wip_features
    # Run tests
    ${FEATURE_TEST_EXE_CMD}
    COMMAND cucumber --tags @wip:3 --wip --tags ~@proposal --no-color -f pretty -s ${CMAKE_CURRENT_SOURCE_DIR}/features
    COMMENT "Running cucumber (wip features)."
  )

  add_dependencies(run_wip_features
    features
  )

  # run wip features target
  add_custom_target(document_features
    # Run tests
    ${FEATURE_TEST_EXE_CMD}
    COMMAND cucumber --tags ~@wip --tags ~@proposal --no-color -f pretty --no-source -f html -o ${DOC_DIR}/Features.html ${CMAKE_CURRENT_SOURCE_DIR}/features
    COMMENT "Running cucumber (features documentation)."
  )

  add_dependencies(document_features
    features
  )

  #############################################
  # Create and run a feature test executable. #
  # With coverage measurement                 #
  #############################################
  if(UNIX AND CMAKE_COMPILER_IS_GNUCXX AND CMAKE_BUILD_TYPE MATCHES Debug)
    include(CodeCoverage)

    add_executable(features-cov
      EXCLUDE_FROM_ALL
      ${STEP_SOURCES}
    )
    target_link_libraries(features-cov
      ${CUKE_LIBRARIES}
      ${Boost_LIBRARIES}
      internal::projectlib-cov
      ${PTREAD_LIB}
      ${RT_LIB}
    )

    if(CMAKE_COMPILER_IS_CLANGCXX)
      target_compile_options(features-cov
        PRIVATE
          -Wno-non-virtual-dtor
          -Wno-global-constructors
      )
    endif(CMAKE_COMPILER_IS_CLANGCXX)

    if(CPPSPEC_FOUND)
      target_include_directories(features-cov
        SYSTEM
        PRIVATE
          ${CPPSPEC_INCLUDE_DIRS}
      )
      target_link_libraries(features-cov
          ${CPPSPEC_LIBRARIES}
      )
    endif(CPPSPEC_FOUND)

    if(GTEST_FOUND)
      target_include_directories(features-cov
        SYSTEM
        PRIVATE
          ${GTEST_INCLUDE_DIRS}
      )
      target_link_libraries(features-cov
        ${GTEST_LIBRARIES}
      )
    endif(GTEST_FOUND)

	if(GMOCK_FOUND)
      target_include_directories(features-cov
        SYSTEM
        PRIVATE
          ${GMOCK_INCLUDE_DIRS}
      )
      target_link_libraries(features-cov
        ${GMOCK_LIBRARIES}
      )
    endif(GMOCK_FOUND)

    setup_target_under_cucumber_for_coverage_cobertura(
      coverage_features
      features-cov
      ${COVERAGE_REPORT_DIR}/features
      ${PROJECT_SOURCE_DIR}/tests/feature/features
      ""
    )
  endif(UNIX AND CMAKE_COMPILER_IS_GNUCXX AND CMAKE_BUILD_TYPE MATCHES Debug)
endif(STEP_SOURCES)
