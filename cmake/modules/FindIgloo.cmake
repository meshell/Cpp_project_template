# Locate Igloo test framework
#
# Defines the following variables:
#
#   IGLOO_FOUND - Found Igloo headerfiles
#   IGLOO_INCLUDE_DIR - Include directories
#

function(IGLOO_ADD_TESTS executable extra_args)
  if(NOT ARGN)
    message(FATAL_ERROR "Missing ARGN: Read the documentation for IGLOO_ADD_TESTS")
  endif()
  foreach(source ${ARGN})
    file(READ "${source}" contents)
      string(REGEX MATCHALL "Context *\\(([A-Za-z_0-9]+)\\)" found_tests ${contents})
      foreach(hit ${found_tests})
        string(REGEX REPLACE ".*\\( *([A-Za-z_0-9]+) *\\).*" "\\1" test_name ${hit})
        add_test(${test_name} ${executable} ${extra_args})
      endforeach()
      
      # 1th Test alternative
      string(REGEX MATCHALL "When *\\(([A-Za-z_0-9]+)\\)" found_tests ${contents})
      foreach(hit ${found_tests})
        string(REGEX REPLACE ".*\\( *([A-Za-z_0-9]+) *\\).*" "\\1" test_name ${hit})
        add_test(${test_name} ${executable} ${extra_args})
      endforeach()
      
      # 2nd Test alternative
      string(REGEX MATCHALL "Describe *\\(([A-Za-z_0-9]+)\\)" found_tests ${contents})
      foreach(hit ${found_tests})
        string(REGEX REPLACE ".*\\( *([A-Za-z_0-9]+) *\\).*" "\\1" test_name ${hit})
        add_test(${test_name} ${executable} ${extra_args})
      endforeach()
  endforeach()
endfunction()

find_path(IGLOO_INCLUDE_DIR igloo/igloo.h 
    HINTS
        ${IGLOO_ROOT}
)


mark_as_advanced(IGLOO_INCLUDE_DIR)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(IGLOO DEFAULT_MSG IGLOO_INCLUDE_DIR)

IF(IGLOO_FOUND)
    SET(IGLOO_INCLUDE_DIRS ${IGLOO_INCLUDE_DIR})
ENDIF()
