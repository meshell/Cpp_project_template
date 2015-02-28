#
# Build library
#

set(${PROJECT_NAME}_SOURCES
  ${SRC_HEADER_FILES}
  dummy.cpp
)

add_library(${@PROJECT_NAME@_LIBRARY}
  STATIC  
  ${@PROJECT_NAME@_SOURCES})

#
# Build main executable
#

#
# with Boost
#
set(CORE_BOOST_LIBS program_options)

if(USE_STATIC_BOOST)
  set(Boost_USE_STATIC_LIBS ON)
else()
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DBOOST_ALL_DYN_LINK")
endif()

find_package(Boost COMPONENTS ${CORE_BOOST_LIBS} REQUIRED)

include_directories(SYSTEM ${Boost_INCLUDE_DIRS})   

add_executable(${PROJECT_NAME} main.cpp)
target_link_libraries(${PROJECT_NAME} ${@PROJECT_NAME@_LIBRARY} ${Boost_LIBRARIES})

#Install targets
install(TARGETS ${@PROJECT_NAME@_LIBRARY}
   ARCHIVE
   DESTINATION dev/lib
   COMPONENT library)

install(TARGETS ${PROJECT_NAME}
   RUNTIME
   DESTINATION bin
   COMPONENT main)
   
 install(FILES ${SRC_HEADER_FILES}
   DESTINATION dev/include
   COMPONENT headers)  

#
# Build library with coverage support
#

if(CMAKE_COMPILER_IS_GNUCXX AND CMAKE_BUILD_TYPE MATCHES Debug)
  include(CodeCoverage)
  
  add_library(${@PROJECT_NAME@_LIBRARY}_coverage
    STATIC
    ${@PROJECT_NAME@_SOURCES}
  )
  set_target_properties(${@PROJECT_NAME@_LIBRARY}_coverage PROPERTIES
        COMPILE_FLAGS "-fprofile-arcs -ftest-coverage"
  )
endif(CMAKE_COMPILER_IS_GNUCXX AND CMAKE_BUILD_TYPE MATCHES Debug)
