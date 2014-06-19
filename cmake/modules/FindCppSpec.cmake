# Locate CppSpec: Behaviour driven development with C++
#
# Defines the following variables:
#
#   CPPSPEC_FOUND - Found CppSpec
#   CPPSPEC_INCLUDE_DIR - Include directories
#   CPPSPEC_LIBRARY - libCppSpec
#

function(_cppspec_append_debugs _endvar _library)
    if(${_library} AND ${_library}_DEBUG)
        set(_output optimized ${${_library}} debug ${${_library}_DEBUG})
    else()
        set(_output ${${_library}})
    endif()
    set(${_endvar} ${_output} PARENT_SCOPE)
endfunction()


find_path(CPPSPEC_INCLUDE_DIR CppSpec/CppSpec.h
    HINTS
        ${CPPSPEC_ROOT}
)

mark_as_advanced(CPPSPEC_INCLUDE_DIR)


function(_cppspec_find_library _name)
    find_library(${_name}
        NAMES ${ARGN}
        HINTS
            ENV CPPSPEC_ROOT
            ${CPPSPEC_ROOT}
    )
    mark_as_advanced(${_name})
endfunction()

function(CPPSPEC_ADD_TESTS executable extra_args)
  if(NOT ARGN)
    message(FATAL_ERROR "Missing ARGN: Read the documentation for CPPSPEC_ADD_TESTS")
  endif()
  foreach(source ${ARGN})
    file(READ "${source}" contents)
    string(REGEX MATCHALL "CppSpec::Specification<[A-Za-z_0-9]+, *([A-Za-z_0-9 ,]+)>" found_tests ${contents})
    foreach(hit ${found_tests})
      string(REGEX REPLACE ".*< *([A-Za-z_0-9]+), *([A-Za-z_0-9]+) *>.*" "\\2" test_name ${hit})
      add_test(NAME "${test_name}" COMMAND ${executable} -s "class ${test_name}" ${extra_args})
    endforeach()
  endforeach()
endfunction()


_cppspec_find_library(CPPSPEC_LIBRARY CppSpec)
_cppspec_find_library(CPPSPEC_LIBRARY_DEBUG CppSpecd)


include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(CPPSPEC DEFAULT_MSG CPPSPEC_LIBRARY CPPSPEC_INCLUDE_DIR)


IF(CPPSPEC_FOUND)
  SET(CPPSPEC_INCLUDE_DIRS ${CPPSPEC_INCLUDE_DIR})
  _cppspec_append_debugs(CPPSPEC_LIBRARIES CPPSPEC_LIBRARY)
ENDIF()
