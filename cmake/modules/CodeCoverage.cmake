# - Enable Code Coverage
#
# 2012-01-31, Lars Bilke
# 2013-07-11, Michel Estermann (modified)
#
# USAGE:
# 1. Copy this file into your cmake modules path
# 2. Add the following line to your CMakeLists.txt:
#      INCLUDE(CodeCoverage)
# 
# 3. Use the function SETUP_TARGET_FOR_COVERAGE to create a custom make target
#    which runs your test executable and produces a lcov code coverage report.
#

# Check prereqs
SET(GCOVR_PATH ${CMAKE_SOURCE_DIR}/scripts/gcovr)
#FIND_PROGRAM( GCOVR_PATH gcovr PATHS ${CMAKE_SOURCE_DIR}/scripts)

IF(NOT CMAKE_COMPILER_IS_GNUCXX)
    MESSAGE(FATAL_ERROR "Compiler is not GNU gcc! Aborting...")
ENDIF() # NOT CMAKE_COMPILER_IS_GNUCXX

IF ( NOT CMAKE_BUILD_TYPE STREQUAL "Debug" )
  MESSAGE( WARNING "Code coverage results with an optimised (non-Debug) build may be misleading" )
ENDIF() # NOT CMAKE_BUILD_TYPE STREQUAL "Debug"

FIND_PROGRAM(PYTHON_EXECUTABLE python)
IF(NOT PYTHON_EXECUTABLE)
    MESSAGE(FATAL_ERROR "Python not found! Aborting...")
ENDIF() # NOT PYTHON_EXECUTABLE

IF(NOT GCOVR_PATH)
    MESSAGE(FATAL_ERROR "gcovr not found! Aborting...")
ENDIF() # NOT GCOVR_PATH

SET(COVERAGE_EXCLUDE "")
IF (EXISTS ${PROJECT_SOURCE_DIR}/tests/coverage.ignore)
    FILE(READ ${PROJECT_SOURCE_DIR}/tests/coverage.ignore CONTENT)
    STRING(REGEX REPLACE "\n" ";" CONTENT "${CONTENT}")
    FOREACH(LINE ${CONTENT})
        SET(COVERAGE_EXCLUDE -e '${LINE}' ${COVERAGE_EXCLUDE})
    ENDFOREACH(LINE)
ENDIF()


# Param _targetname     The name of new the custom make target
# Param _testrunner     The name of the target which runs the tests
# Param _outputname     cobertura output is generated as _outputname.xml
# Optional fourth parameter is passed as arguments to _testrunner
# Optional fifth parameter is passed as arguments to gcovr
#   Pass them in list form, e.g.: "-j;2" for -j 2
FUNCTION(SETUP_TARGET_FOR_COVERAGE_COBERTURA _targetname _testrunner _outputname)
    TARGET_LINK_LIBRARIES(${_testrunner} gcov)
    set_target_properties(${_testrunner} PROPERTIES 
        COMPILE_FLAGS "-fprofile-arcs -ftest-coverage"
    )

    ADD_CUSTOM_TARGET(${_targetname}

        # Run tests
        ${_testrunner} ${ARGV3}

        # Running gcovr
        COMMAND ${GCOVR_PATH} -x -r ${CMAKE_SOURCE_DIR} -e '${CMAKE_SOURCE_DIR}/tests/unit' -o ${_outputname}.xml ${COVERAGE_EXCLUDE} ${ARGV4}
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "Running gcovr to produce Cobertura code coverage report."
    )

    # Show info where to find the report
    ADD_CUSTOM_COMMAND(TARGET ${_targetname} POST_BUILD
        COMMAND ;
        COMMENT "Cobertura code coverage report saved in ${_outputname}.xml."
    )
ENDFUNCTION() # SETUP_TARGET_FOR_COVERAGE_COBERTURA



# Param _targetname     The name of new the custom make target
# Param _testrunner     The name of the target which runs the tests
# Param _outputname     cobertura output is generated as _outputname.xml
# Optional _features param path to feature files
# Optional fifth parameter is passed as arguments to _testrunner
#   Pass them in list form, e.g.: "-j;2" for -j 2
# Optional sixth parameter is passed as arguments to gcovr
FUNCTION(SETUP_TARGET_UNDER_CUCUMBER_FOR_COVERAGE_COBERTURA _targetname _testrunner _outputname _features)
    TARGET_LINK_LIBRARIES(${_testrunner} gcov)
    set_target_properties(${_testrunner} PROPERTIES 
        COMPILE_FLAGS "-fprofile-arcs -ftest-coverage"
    )

    ADD_CUSTOM_TARGET(${_targetname}_cucumber
        # Run tests
        ${_testrunner}  ${ARGV4} &

        COMMAND cucumber --tags ~@wip --no-color -f pretty -s -f junit -o ${TESTS_REPORT_DIR} ${_features}
        COMMENT "Running cucumber to produce coverage informations."
    )

    ADD_CUSTOM_TARGET(${_targetname}
        # Running gcovr
        ${GCOVR_PATH} -x -r ${CMAKE_SOURCE_DIR} -e '${CMAKE_SOURCE_DIR}/tests/feature' -o ${_outputname}.xml ${COVERAGE_EXCLUDE} ${ARGV5}
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "Running gcovr to produce Cobertura code coverage report."
    )

    ADD_DEPENDENCIES(
        ${_targetname}
        ${_targetname}_cucumber
        )

    # Show info where to find the report
    ADD_CUSTOM_COMMAND(TARGET ${_targetname} POST_BUILD
        COMMAND ;
        COMMENT "Cobertura code coverage report saved in ${_outputname}.xml."
    )

ENDFUNCTION() # SETUP_TARGET_UNDER_CUCUMBER_FOR_COVERAGE_COBERTURA

# Param _targetname     The name of new the custom make target
# Param _testrunner     The name of the target which runs the tests
# Param _outputname     cobertura output is generated as _outputname.xml
# Optional fourth parameter is passed as arguments to _testrunner
# Optional fifth parameter is passed as arguments to gcovr
#   Pass them in list form, e.g.: "-j;2" for -j 2
FUNCTION(SETUP_TARGET_SPEC_FOR_COVERAGE_COBERTURA _targetname _testrunner _outputname)
    TARGET_LINK_LIBRARIES(${_testrunner} gcov)
    set_target_properties(${_testrunner} PROPERTIES 
        COMPILE_FLAGS "-fprofile-arcs -ftest-coverage"
    )

    ADD_CUSTOM_TARGET(${_targetname}

        # Run tests
        ${_testrunner} ${ARGV3}

        # Running gcovr
        COMMAND ${GCOVR_PATH} -d -x -r ${CMAKE_SOURCE_DIR} -e '${CMAKE_SOURCE_DIR}/tests/spec' -o ${_outputname}.xml ${COVERAGE_EXCLUDE} ${ARGV4}
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "Running gcovr to produce Cobertura code coverage report."
    )

    # Show info where to find the report
    ADD_CUSTOM_COMMAND(TARGET ${_targetname} POST_BUILD
        COMMAND ;
        COMMENT "Cobertura code coverage report saved in ${_outputname}.xml."
    )
ENDFUNCTION() # SETUP_TARGET_SPEC_FOR_COVERAGE_COBERTURA


# Param _targetname     The name of new the custom make target
# Param _testrunner     The name of the target which runs the tests
# Param _outputname     cobertura output is generated as _outputname.xml
# Optional fourth parameter is passed as arguments to _testrunner
# Optional fifth parameter is the outputfile the output is redirected to
# Optional sixth parameter is passed as arguments to gcovr
#   Pass them in list form, e.g.: "-j;2" for -j 2
FUNCTION(SETUP_TARGET_FOR_IGLOO_COVERAGE_COBERTURA _targetname _testrunner _outputname)
    TARGET_LINK_LIBRARIES(${_testrunner} gcov)
    set_target_properties(${_testrunner} PROPERTIES 
        COMPILE_FLAGS "-fprofile-arcs -ftest-coverage"
    )

    ADD_CUSTOM_TARGET(${_targetname}

        # Run tests
        ${_testrunner} ${ARGV3} > ${ARGV4}

        # Running gcovr
        COMMAND ${GCOVR_PATH} -x -r ${CMAKE_SOURCE_DIR} -e '${CMAKE_SOURCE_DIR}/tests/igloo' -o ${_outputname}.xml ${COVERAGE_EXCLUDE} ${ARGV5}
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "Running gcovr to produce Cobertura code coverage report."
    )

    # Show info where to find the report
    ADD_CUSTOM_COMMAND(TARGET ${_targetname} POST_BUILD
        COMMAND ;
        COMMENT "Cobertura code coverage report saved in ${_outputname}.xml."
    )
ENDFUNCTION() # SETUP_TARGET_FOR_IGLOO_COVERAGE_COBERTURA

