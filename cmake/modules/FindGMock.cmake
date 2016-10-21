# Locate the Google C++ Mocking Framework.
# (This file is almost an identical copy of the original FindGTest.cmake file,
#  feel free to use it as it is or modify it for your own needs.)
# Imported targets
# ^^^^^^^^^^^^^^^^
#
# This module defines the following :prop_tgt:`IMPORTED` targets:
#
# ``GMock::GMock``
#   The Google Mock ``gmock`` library, if found; adds Thread::Thread
#   automatically
# ``GMock::Main``
#   The Google Mock ``gmock_main`` library, if found
#
#
# Result variables
# ^^^^^^^^^^^^^^^^
#
# This module will set the following variables in your project:
#
# ``GMOCK_FOUND``
#   Found the Google Mocking framework
# ``GMOCK_INCLUDE_DIRS``
#   the directory containing the Google Mock headers
#
# The library variables below are set as normal variables.  These
# contain debug/optimized keywords when a debugging library is found.
#
# ``GMOCK_LIBRARIES``
#   The Google Mock ``gmock`` library; note it also requires linking
#   with an appropriate thread library
# ``GMOCK_MAIN_LIBRARIES``
#   The Google Mock ``gmock_main`` library
# ``GMOCK_BOTH_LIBRARIES``
#   Both ``gmock`` and ``gmock_main``
#
# Cache variables
# ^^^^^^^^^^^^^^^
#
# The following cache variables may also be set:
#
# ``GMOCK_ROOT``
#   The root directory of the Google Mock installation (may also be
#   set as an environment variable)
# ``GMOCK_MSVC_SEARCH``
#   If compiling with MSVC, this variable can be set to ``MD`` or
#   ``MT`` (the default) to enable searching a GMock build tree
#
#
# Example usage
# ^^^^^^^^^^^^^
#
# ::
#
#     enable_testing()
#     find_package(GMock REQUIRED)
#
#     add_executable(foo foo.cc)
#     target_link_libraries(foo GMock::GMock GMock::Main)
#
#     add_test(AllTestsInFoo foo)
#
#
# Deeper integration with CTest
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
# If you would like each Google Mock to show up in CTest as a test you
# may use the following macro::
#
#     GMOCK_ADD_TESTS(executable extra_args files...)
#
# ``executable``
#   the path to the test executable
# ``extra_args``
#   a list of extra arguments to be passed to executable enclosed in
#   quotes (or ``""`` for none)
# ``files...``
#   a list of source files to search for tests and test fixtures.  Or
#   ``AUTO`` to find them from executable target
#
# However, note that this macro will slow down your tests by running
# an executable for each test and test fixture.  You will also have to
# re-run CMake after adding or removing tests or test fixtures.
#
# Example usage::
#
#      set(FooTestArgs --foo 1 --bar 2)
#      add_executable(FooTest FooUnitTest.cc)
#      GMOCK_ADD_TESTS(FooTest "${FooTestArgs}" AUTO)

#=============================================================================
# Copyright 2009 Kitware, Inc.
# Copyright 2009 Philip Lowman <philip@yhbt.com>
# Copyright 2009 Daniel Blezek <blezek@gmail.com>
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file Copyright.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distribute this file outside of CMake, substitute the full
#  License text for the above reference.)
#
function(_gmock_append_debugs _endvar _library)
    if(${_library} AND ${_library}_DEBUG)
        set(_output optimized ${${_library}} debug ${${_library}_DEBUG})
    else()
        set(_output ${${_library}})
    endif()
    set(${_endvar} ${_output} PARENT_SCOPE)
endfunction()

function(_gmock_find_library _name)
    find_library(${_name}
        NAMES ${ARGN}
        HINTS
            ENV GMOCK_ROOT
            ${GMOCK_ROOT}
        PATH_SUFFIXES ${_gmock_libpath_suffixes}
    )
    mark_as_advanced(${_name})
endfunction()

if(NOT DEFINED GMOCK_MSVC_SEARCH)
    set(GMOCK_MSVC_SEARCH MD)
endif()

set(_gmock_libpath_suffixes lib)
if(MSVC)
    if(GMOCK_MSVC_SEARCH STREQUAL "MD")
        list(APPEND _gmock_libpath_suffixes
            msvc/gmock-md/Debug
            msvc/gmock-md/Release)
    elseif(GMOCK_MSVC_SEARCH STREQUAL "MT")
        list(APPEND _gmock_libpath_suffixes
            msvc/gmock/Debug
            msvc/gmock/Release)
    endif()
endif()


find_path(GMOCK_INCLUDE_DIR gmock/gmock.h
    HINTS
        $ENV{GMOCK_ROOT}/include
        ${GMOCK_ROOT}/include
)
mark_as_advanced(GMOCK_INCLUDE_DIR)

if(MSVC AND GMOCK_MSVC_SEARCH STREQUAL "MD")
    # The provided /MD project files for Google Mock add -md suffixes to the
    # library names.
    _gmock_find_library(GMOCK_LIBRARY            gmock-md  gmock)
    _gmock_find_library(GMOCK_LIBRARY_DEBUG      gmock-mdd gmockd)
    _gmock_find_library(GMOCK_MAIN_LIBRARY       gmock_main-md  gmock_main)
    _gmock_find_library(GMOCK_MAIN_LIBRARY_DEBUG gmock_main-mdd gmock_maind)
else()
    _gmock_find_library(GMOCK_LIBRARY            gmock)
    _gmock_find_library(GMOCK_LIBRARY_DEBUG      gmockd)
    _gmock_find_library(GMOCK_MAIN_LIBRARY       gmock_main)
    _gmock_find_library(GMOCK_MAIN_LIBRARY_DEBUG gmock_maind)
endif()

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(GMock DEFAULT_MSG GMOCK_LIBRARY GMOCK_INCLUDE_DIR GMOCK_MAIN_LIBRARY)

if(GMOCK_FOUND)
    set(GMOCK_INCLUDE_DIRS ${GMOCK_INCLUDE_DIR})
    _gmock_append_debugs(GMOCK_LIBRARIES      GMOCK_LIBRARY)
    _gmock_append_debugs(GMOCK_MAIN_LIBRARIES GMOCK_MAIN_LIBRARY)
    set(GMOCK_BOTH_LIBRARIES ${GMOCK_LIBRARIES} ${GMOCK_MAIN_LIBRARIES})

    include(CMakeFindDependencyMacro)
    find_dependency(Threads)

    if(NOT TARGET GMock::GMock)
        add_library(GMock::GMock UNKNOWN IMPORTED)
        set_target_properties(GMock::GMock PROPERTIES
            INTERFACE_LINK_LIBRARIES "Threads::Threads")
        if(GMOCK_INCLUDE_DIRS)
            set_target_properties(GMock::GMock PROPERTIES
                INTERFACE_INCLUDE_DIRECTORIES "${GMOCK_INCLUDE_DIRS}")
        endif()
        if(EXISTS "${GMOCK_LIBRARY}")
            set_target_properties(GMock::GMock PROPERTIES
                IMPORTED_LINK_INTERFACE_LANGUAGES "CXX"
                IMPORTED_LOCATION "${GMOCK_LIBRARY}")
        endif()
        if(EXISTS "${GMOCK_LIBRARY_DEBUG}")
            set_property(TARGET GMock::GMock APPEND PROPERTY
                IMPORTED_CONFIGURATIONS DEBUG)
            set_target_properties(GMock::GMock PROPERTIES
                IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "CXX"
                IMPORTED_LOCATION_DEBUG "${GMOCK_LIBRARY_DEBUG}")
        endif()
        if(EXISTS "${GMOCK_LIBRARY_RELEASE}")
            set_property(TARGET GMock::GMock APPEND PROPERTY
                IMPORTED_CONFIGURATIONS RELEASE)
            set_target_properties(GMock::GMock PROPERTIES
                IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "CXX"
                IMPORTED_LOCATION_RELEASE "${GMOCK_LIBRARY_RELEASE}")
        endif()
      endif()
      if(NOT TARGET GMock::Main)
          add_library(GMock::Main UNKNOWN IMPORTED)
          set_target_properties(GMock::Main PROPERTIES
              INTERFACE_LINK_LIBRARIES "GMock::GMock")
          if(EXISTS "${GMOCK_MAIN_LIBRARY}")
              set_target_properties(GMock::Main PROPERTIES
                  IMPORTED_LINK_INTERFACE_LANGUAGES "CXX"
                  IMPORTED_LOCATION "${GMOCK_MAIN_LIBRARY}")
          endif()
          if(EXISTS "${GMOCK_MAIN_LIBRARY_DEBUG}")
            set_property(TARGET GMock::Main APPEND PROPERTY
                IMPORTED_CONFIGURATIONS DEBUG)
            set_target_properties(GMock::Main PROPERTIES
                IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "CXX"
                IMPORTED_LOCATION_DEBUG "${GMOCK_MAIN_LIBRARY_DEBUG}")
          endif()
          if(EXISTS "${GMOCK_MAIN_LIBRARY_RELEASE}")
            set_property(TARGET GMock::Main APPEND PROPERTY
                IMPORTED_CONFIGURATIONS RELEASE)
            set_target_properties(GMock::Main PROPERTIES
                IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "CXX"
                IMPORTED_LOCATION_RELEASE "${GMOCK_MAIN_LIBRARY_RELEASE}")
          endif()
    endif()
endif()
