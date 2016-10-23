# Locate Cucumber-cpp: Cucumber-Cpp allows Cucumber to support step definitions written in C++
#
# Defines the following variables:
#
#   CUKE_FOUND - Found cucumber-cpp
#   CUKE_INCLUDE_DIR - Include directories
#   CUKE_LIBRARY - libcucumber-cpp
#

function(_cuke_append_debugs _endvar _library)
    if(${_library} AND ${_library}_DEBUG)
        set(_output optimized ${${_library}} debug ${${_library}_DEBUG})
    else()
        set(_output ${${_library}})
    endif()
    set(${_endvar} ${_output} PARENT_SCOPE)
endfunction()


find_path(CUKE_INCLUDE_DIR cucumber-cpp/internal/CukeCommands.hpp 
    HINTS
        ${CUKE_ROOT}
)


mark_as_advanced(CUKE_INCLUDE_DIR)

function(_cuke_find_library _name)
    find_library(${_name}
        NAMES ${ARGN}
        HINTS
            ENV CUKE_ROOT
            ${CUKE_ROOT}
    )
    mark_as_advanced(${_name})
endfunction()

_cuke_find_library(CUKE_LIBRARY cucumber-cpp)
_cuke_find_library(CUKE_LIBRARY_DEBUG cucumber-cppd)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(CUKE DEFAULT_MSG CUKE_LIBRARY CUKE_INCLUDE_DIR)

if(CUKE_FOUND)
    SET(CUKE_INCLUDE_DIRS ${CUKE_INCLUDE_DIR})
    _cuke_append_debugs(CUKE_LIBRARIES CUKE_LIBRARY)

    if(NOT TARGET Cuke::Cucumber-cpp)
        add_library(Cuke::Cucumber-cpp UNKNOWN IMPORTED)
        if(CUKE_INCLUDE_DIRS)
            set_target_properties(Cuke::Cucumber-cpp PROPERTIES
                INTERFACE_INCLUDE_DIRECTORIES "${CUKE_INCLUDE_DIRS}")
        endif()
        if(EXISTS "${CUKE_LIBRARY}")
            set_target_properties(Cuke::Cucumber-cpp PROPERTIES
                IMPORTED_LINK_INTERFACE_LANGUAGES "CXX"
                IMPORTED_LOCATION "${CUKE_LIBRARY}")
        endif()
        if(EXISTS "${CUKE_LIBRARY_DEBUG}")
            set_property(TARGET Cuke::Cucumber-cpp APPEND PROPERTY
                IMPORTED_CONFIGURATIONS DEBUG)
            set_target_properties(Cuke::Cucumber-cpp PROPERTIES
                IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "CXX"
                IMPORTED_LOCATION_DEBUG "${CUKE_LIBRARY_DEBUG}")
        endif()
        if(EXISTS "${CUKE_LIBRARY_RELEASE}")
            set_property(TARGET Cuke::Cucumber-cpp APPEND PROPERTY
                IMPORTED_CONFIGURATIONS RELEASE)
            set_target_properties(Cuke::Cucumber-cpp PROPERTIES
                IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "CXX"
                IMPORTED_LOCATION_RELEASE "${CUKE_LIBRARY_RELEASE}")
        endif()
    endif()
endif()
