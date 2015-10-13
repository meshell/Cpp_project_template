# required minimum version of cmake
cmake_minimum_required(VERSION 3.2 FATAL_ERROR)

option(USE_STATIC_BOOST "Statically link Boost" ${WIN32})

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

# TODO add all your step definition files here (source file wothout extension)
if(CUKE_FOUND)
  register_feature_steps(features/step_definitions/dummy_steps)
  register_feature_steps(features/step_definitions/mock_steps)
endif(CUKE_FOUND)

if(STEP_SOURCES)
  # Find all feature files
  FILE(GLOB_RECURSE FEATURE_FILES features *.feature)

  source_group("Feature Files" FILES ${FEATURE_FILES})

  add_executable(features
      ${STEP_SOURCES}
      ${FEATURE_FILES}
  )

  add_executable(tests::features ALIAS features)

  #
  # Boost
  #
  if(USE_STATIC_BOOST)
    set(Boost_USE_STATIC_LIBS ON)
  else(USE_STATIC_BOOST)
    target_compile_definitions(features
        PRIVATE
        BOOST_ALL_DYN_LINK
    )
  endif(USE_STATIC_BOOST)

  set(CORE_BOOST_LIBS thread system regex date_time)

  find_package(CppSpec)
  if(CPPSPEC_FOUND)
    set(CORE_BOOST_LIBS ${CORE_BOOST_LIBS} chrono)
  endif(CPPSPEC_FOUND)

  find_package(Boost COMPONENTS  ${CORE_BOOST_LIBS} REQUIRED)

  target_include_directories(features
      SYSTEM
      PRIVATE
      ${CUKE_INCLUDE_DIRS}
      ${Boost_INCLUDE_DIRS}
  )

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
  #
  # CppSpec driver
  #
  find_package(CppSpec)

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

  #
  # Google Test driver
  #
  find_package(GTest REQUIRED)

  if(GTEST_FOUND)
    target_include_directories(features
        SYSTEM
        PRIVATE
        ${GTEST_INCLUDE_DIRS}
    )
    target_link_libraries(features
        ${GTEST_LIBRARIES}
    )

    if(UNIX)
      find_package(Threads) # GTest needs this and it's a static library
      target_link_libraries(features
          ${CMAKE_THREAD_LIBS_INIT}
      )
    endif(UNIX)
  endif(GTEST_FOUND)

  #
  # For using Google Mock
  #
  find_package(GMock)

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

  if(WIN32)
    target_link_libraries(features
        ws2_32
    )
  endif(WIN32)

  ###############################
  # Installing gem dependencies
  ###############################  
  find_program(BUNDLE bundle)
  if(BUNDLE)
    message(STATUS "Installing gem dependencies")
    execute_process(COMMAND ${BUNDLE} WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
  else(BUNDLE)
    message(WARNING "Could not find Bundler: skipping Ruby Gem management")
  endif(BUNDLE)

  ###############################
  # Create run targets if cucumber is installed
  ###############################
  find_program(CUCUMBER_RUBY cucumber)
  if(CUCUMBER_RUBY)
    if(WIN32)
      if(MSVC)
        set(FEATURE_TEST_EXE_CMD start /B ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/features.exe)
      else(MSVC)
        set(FEATURE_TEST_EXE_CMD start /B ${CMAKE_CURRENT_BINARY_DIR}/features.exe)
      endif(MSVC)
    else(WIN32)
      set(FEATURE_TEST_EXE_CMD ${CMAKE_CURRENT_BINARY_DIR}/features &)
    endif(WIN32)

    message(STATUS "Found Cucumber")
    # Target: run feature tests
    # Run all features except features tagged  @wip or @proposal
    add_custom_target(run_feature_test
        ${FEATURE_TEST_EXE_CMD}
        COMMAND cucumber -P --tags ~@wip --tags ~@proposal --no-color -f pretty -s features
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "Running cucumber."
    )

    add_dependencies(run_feature_test
        tests::features
    )

    # Target: run wip features
    # Run cucumber with --wip argument and run only features tagged @wip
    add_custom_target(run_wip_features
        ${FEATURE_TEST_EXE_CMD}
        COMMAND cucumber -P --tags @wip:3 --wip --tags ~@proposal --no-color -f pretty -s features
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "Running cucumber (wip features)."
    )

    add_dependencies(run_wip_features
        features
    )

    # Target: document features
    # Run all features except features tagged @wip or @proposal and generate html output
    add_custom_target(document_features
        ${FEATURE_TEST_EXE_CMD}
        COMMAND cucumber -P --tags ~@wip --tags ~@proposal --no-color -f pretty --no-source -f html -o ${DOC_DIR}/Features.html features
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "Running cucumber (features documentation)."
    )

    add_dependencies(document_features
        features
    )
  else(CUCUMBER_RUBY)
    message(WARNING "Could not find Cucumber: Install cucumber first in order to run tests")
  endif(CUCUMBER_RUBY)

  #############################################
  # Create and run a feature test executable. #
  # With coverage measurement                 #
  #############################################
  if(UNIX AND CMAKE_COMPILER_IS_GNUCXX AND CMAKE_BUILD_TYPE MATCHES Debug)
    include(CodeCoverageCucumber)

    add_executable(features-cov
        EXCLUDE_FROM_ALL
        ${STEP_SOURCES}
    )
    target_include_directories(features-cov
        SYSTEM
        PRIVATE
        ${CUKE_INCLUDE_DIRS}
        ${Boost_INCLUDE_DIRS}
    )
    target_link_libraries(features-cov
        ${CUKE_LIBRARIES}
        ${Boost_LIBRARIES}
        internal::projectlib-cov
        ${CMAKE_THREAD_LIBS_INIT}
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
        ${CMAKE_CURRENT_SOURCE_DIR}
        ""
    )
  endif(UNIX AND CMAKE_COMPILER_IS_GNUCXX AND CMAKE_BUILD_TYPE MATCHES Debug)
endif(STEP_SOURCES)
