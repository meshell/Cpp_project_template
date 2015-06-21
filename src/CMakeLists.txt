# required minimum version of cmake
cmake_minimum_required(VERSION 3.2 FATAL_ERROR)

# set the path to the additional cmake modules
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../cmake/modules)

# set default built type to Debug
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Debug)
endif(NOT CMAKE_BUILD_TYPE)

# Check for clang compiler
if(CMAKE_CXX_COMPILER MATCHES ".*clang")
  set(CMAKE_COMPILER_IS_CLANGCXX 1)
endif()

# Cache options
option(USE_STATIC_BOOST "Statically link Boost" ${WIN32})

# set path to externals
set(CMAKE_INCLUDE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../externals/include)
set(CMAKE_LIBRARY_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../externals/lib)

# configure a header file to pass the version number to the source code

configure_file (
  "${CMAKE_CURRENT_SOURCE_DIR}/../project_version.h.in"
  "${CMAKE_CURRENT_SOURCE_DIR}/../include/project_version.h"
)

#
# Build library for internal use only (unittests)
#

add_library(projectlib STATIC
    EXCLUDE_FROM_ALL
    dummy.cpp
)

add_library(internal::projectlib ALIAS projectlib)

target_include_directories(projectlib
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/../include
)

if(CMAKE_COMPILER_IS_GNUCXX)
    target_compile_options(projectlib
        PUBLIC
            -pedantic
            -Wall
            -Wextra
        PRIVATE
            -Werror
            -Wcast-align
            -Wcast-qual
            -Wctor-dtor-privacy
            -Wdisabled-optimization
            -Wformat=2
            -Winit-self
            -Wlogical-op
            -Wmissing-declarations
            -Wmissing-include-dirs
            -Wnoexcept
            -Wold-style-cast
            -Woverloaded-virtual
            -Wredundant-decls
            -Wshadow
            -Wsign-conversion
            -Wsign-promo
            -Wstrict-null-sentinel
            -Wstrict-overflow=5
            -Wswitch-default
            -Wundef
    )

elseif(CMAKE_COMPILER_IS_CLANGCXX)
    target_compile_options(projectlib
        PUBLIC
            -Weverything
            -Wno-c++98-compat
            -Wno-padded
        PRIVATE
            -Werror
    )
endif(CMAKE_COMPILER_IS_GNUCXX)

# Define some common C++11 features
target_compile_features(projectlib
    PUBLIC
        cxx_auto_type
        cxx_constexpr
        cxx_defaulted_functions
        cxx_defaulted_move_initializers
        cxx_delegating_constructors
        cxx_deleted_functions
        cxx_final
        cxx_lambdas
        cxx_nullptr
        cxx_override
        cxx_range_for
        cxx_rvalue_references
        cxx_strong_enums
)

#
# Build main executable
#

#
# with Boost
#
add_executable(${PROJECT_NAME}
    main.cpp
)
add_executable(${PROJECT_NAME}::exe ALIAS ${PROJECT_NAME})

find_package(Boost COMPONENTS program_options REQUIRED)

target_include_directories(${PROJECT_NAME}
    SYSTEM
    PRIVATE
        ${Boost_INCLUDE_DIRS}
)

if(USE_STATIC_BOOST)
  set(Boost_USE_STATIC_LIBS ON)
else(USE_STATIC_BOOST)
    target_compile_definitions(${PROJECT_NAME}
        PRIVATE
            BOOST_ALL_DYN_LINK
    )
endif(USE_STATIC_BOOST)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
        internal::projectlib
        ${Boost_LIBRARIES}
)

#Install targets
install(TARGETS ${PROJECT_NAME}
   RUNTIME DESTINATION bin
   COMPONENT main
)

install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/../include/dummy.h
    DESTINATION include/${PROJECT_NAME}
    COMPONENT headers
)

#
# Build library with coverage support
#

if(CMAKE_COMPILER_IS_GNUCXX AND CMAKE_BUILD_TYPE MATCHES Debug)
    add_library(projectlib-cov
        EXCLUDE_FROM_ALL
        dummy.cpp
    )
    add_library(internal::projectlib-cov ALIAS projectlib-cov)

    target_compile_options(projectlib-cov
        PUBLIC
            -fprofile-arcs
            -ftest-coverage
            -pedantic
            -Wall
            -Wextra
        PRIVATE
            -Werror
    )

    target_include_directories(projectlib-cov
        PUBLIC
            ${CMAKE_CURRENT_SOURCE_DIR}/../include
    )

    target_compile_features(projectlib-cov
        PUBLIC
            cxx_auto_type
            cxx_constexpr
            cxx_defaulted_functions
            cxx_defaulted_move_initializers
            cxx_delegating_constructors
            cxx_deleted_functions
            cxx_final
            cxx_lambdas
            cxx_nullptr
            cxx_override
            cxx_range_for
            cxx_rvalue_references
            cxx_strong_enums
    )

    export(TARGETS projectlib projectlib-cov NAMESPACE internal:: FILE ${CMAKE_CURRENT_SOURCE_DIR}/../project-export.cmake)
else(CMAKE_COMPILER_IS_GNUCXX AND CMAKE_BUILD_TYPE MATCHES Debug)
    export(TARGETS projectlib NAMESPACE internal:: FILE ${CMAKE_CURRENT_SOURCE_DIR}/../project-export.cmake)
endif(CMAKE_COMPILER_IS_GNUCXX AND CMAKE_BUILD_TYPE MATCHES Debug)
