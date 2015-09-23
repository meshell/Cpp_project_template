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

# Check for clang compiler
if(CMAKE_CXX_COMPILER MATCHES ".*clang")
  set(CMAKE_COMPILER_IS_CLANGCXX 1)
endif()

#########################################################################
# Create test executables for every testclass (no coverage measurement) #
#########################################################################

find_package(GMock REQUIRED)
find_package(GTest REQUIRED)

if(NOT TARGET internal::projectlib)
    include(${CMAKE_CURRENT_SOURCE_DIR}/../../project-export.cmake)
endif()

function(register_test TEST_FILE)
    get_filename_component(TEST_NAME ${TEST_FILE} NAME)
    message(STATUS "Adding " ${TEST_NAME})
    add_executable(${TEST_NAME} ${TEST_FILE}.cpp)
    target_include_directories(${TEST_NAME}
        SYSTEM
        PRIVATE
            ${GTEST_INCLUDE_DIRS}
            ${GMOCK_INCLUDE_DIRS}
    )
    target_link_libraries(${TEST_NAME}
        ${GTEST_BOTH_LIBRARIES}
        ${GMOCK_BOTH_LIBRARIES}
        internal::projectlib ${ARGN}
    )

    if(CMAKE_COMPILER_IS_CLANGCXX)
        target_compile_options(${TEST_NAME}
            PRIVATE
                -Wno-global-constructors
        )
    endif(CMAKE_COMPILER_IS_CLANGCXX)

    if(UNIX)
        find_package(Threads) # GTest needs this and it's a static library
        target_link_libraries(${TEST_NAME}
            ${CMAKE_THREAD_LIBS_INIT}
        )
    endif(UNIX)
	
    gtest_add_tests(${TEST_NAME} "" ${TEST_FILE}.cpp)
    set(UNITTEST_SOURCES ${UNITTEST_SOURCES} ${TEST_FILE}.cpp PARENT_SCOPE)
endfunction()

register_test(src/dummy_test)

############################################################
# Create a single test executable including all testclass. #
# Without coverage measurement                             #
############################################################

add_executable(unittests ${UNITTEST_SOURCES})
add_executable(tests::unit ALIAS unittests)

target_include_directories(unittests
    SYSTEM
    PRIVATE
        ${GTEST_INCLUDE_DIRS}
        ${GMOCK_INCLUDE_DIRS}
)

target_link_libraries(unittests
    ${GTEST_BOTH_LIBRARIES}
    ${GMOCK_BOTH_LIBRARIES}
    internal::projectlib
)

if(CMAKE_COMPILER_IS_CLANGCXX)
    target_compile_options(unittests
        PRIVATE
            -Wno-global-constructors
    )
endif(CMAKE_COMPILER_IS_CLANGCXX)

if(UNIX)
    find_package(Threads) # GTest needs this and it's a static library
    target_link_libraries(unittests
        ${CMAKE_THREAD_LIBS_INIT}
    )
endif(UNIX)

# run allways unit tests target when make all
add_custom_target(run_unittests
    ALL
        unittests --gtest_shuffle
)

add_dependencies(run_unittests
    tests::unit
)

add_custom_target(run_unittests_xunit
    unittests --gtest_output=xml:${TESTS_REPORT_DIR}/unittests.xml
)

add_dependencies(run_unittests_xunit
    tests::unit
)

####################################################################
# Create and run a single test executable including all testclass. #
# With coverage measurement                                        #
####################################################################
if(UNIX AND CMAKE_COMPILER_IS_GNUCXX AND CMAKE_BUILD_TYPE MATCHES Debug)
    include(CodeCoverage)
    add_executable(unittests-cov
        EXCLUDE_FROM_ALL
        ${UNITTEST_SOURCES})

    target_include_directories(unittests-cov
        SYSTEM
        PRIVATE
            ${GTEST_INCLUDE_DIRS}
            ${GMOCK_INCLUDE_DIRS}
    )

    target_link_libraries(unittests-cov
        ${GTEST_BOTH_LIBRARIES}
        ${GMOCK_BOTH_LIBRARIES}
        internal::projectlib-cov
    )

    if(CMAKE_COMPILER_IS_CLANGCXX)
        target_compile_options(unittests-cov
            PRIVATE
                -Wno-global-constructors
        )
    endif(CMAKE_COMPILER_IS_CLANGCXX)

    if(UNIX)
        find_package(Threads) # GTest needs this and it's a static library
        target_link_libraries(unittests-cov
            ${CMAKE_THREAD_LIBS_INIT}
        )
    endif(UNIX)
    setup_target_for_coverage_cobertura(coverage_unittests
        unittests-cov
        ${COVERAGE_REPORT_DIR}/unittests
        "--gtest_output='xml:${TESTS_REPORT_DIR}/unittests.xml'"
    )
endif(UNIX AND CMAKE_COMPILER_IS_GNUCXX AND CMAKE_BUILD_TYPE MATCHES Debug)

