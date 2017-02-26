# Locate Catch test framework
#
# Defines the following variables:
#
#   CATCH_FOUND - Found Catch headerfile
#   CATCH_INCLUDE_DIR - Include directories
#

function(catch_add_tests executable extra_args)
  if(NOT ARGN)
    message(FATAL_ERROR "Missing ARGN: Read the documentation for CATCH_ADD_TESTS")
  endif()
  foreach(source ${ARGN})
    file(READ "${source}" contents)
    string(REGEX MATCHALL "TEST_CASE *\\( *\"([ A-Za-z_0-9]+)\" *, *\"\\[[ A-Za-z_0-9]*\\]\" *\\)" found_tests ${contents})
    foreach(hit ${found_tests})
      string(REGEX REPLACE "TEST_CASE *\\( *\"([ A-Za-z_0-9]+)\".*" "\\1" test_name ${hit})
      string(REPLACE " " "_" test_name_underscore ${test_name})
      add_test(${test_name_underscore} ${executable} ${extra_args})
    endforeach()

    # Test alternative
    string(REGEX MATCHALL "SCENARIO *\\( *\"([ A-Za-z_0-9]+)\" *, *\"\\[[ A-Za-z_0-9]*\\]\" *\\)" found_tests ${contents})
    foreach(hit ${found_tests})
      string(REGEX REPLACE "SCENARIO *\\( *\"([ A-Za-z_0-9]+)\".*" "\\1" test_name ${hit})
      string(REPLACE " " "_" test_name_underscore ${test_name})
      add_test(${test_name_underscore} ${executable} ${extra_args})
    endforeach()
  endforeach()
endfunction()

find_path(CATCH_INCLUDE_DIR catch/catch.hpp
    HINTS
    ${CATCH_ROOT}
    )


mark_as_advanced(CATCH_INCLUDE_DIR)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(CATCH DEFAULT_MSG CATCH_INCLUDE_DIR)

if(CATCH_FOUND)
  set(CATCH_INCLUDE_DIRS ${CATCH_INCLUDE_DIR})
endif()
