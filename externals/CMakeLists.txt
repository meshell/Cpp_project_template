option(DISABLE_CPPSPEC "Do not use CppSpec" FALSE)
option(DISABLE_IGLOO "Do not use Igloo testing framework" FALSE)
option(DISABLE_CATCH "Do not use CATCH testing framework" FALSE)

# CMake file to build the external dependencies
cmake_minimum_required(VERSION 2.8 FATAL_ERROR)

# set the path to the additional cmake modules
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../cmake/modules)

# set default built type to Debug
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Debug)
endif(NOT CMAKE_BUILD_TYPE)

include(ExternalProject)

# create output directories
file(MAKE_DIRECTORY
  ${CMAKE_CURRENT_SOURCE_DIR}/lib
  ${CMAKE_CURRENT_SOURCE_DIR}/include
)

set(CMAKE_PREFIX_PATH ${CMAKE_CURRENT_SOURCE_DIR})
if(MSVC)
  set(SCRIPT_SUFFIX .bat)
else(MSVC)
  set(SCRIPT_SUFFIX .sh)
endif(MSVC)

set(LIB_DIR "")

#TODO USe this one if build from Visual Studio Solution
#set(LIB_DIR "Debug")

# Add an target to build all external dependencies
add_custom_target(external_dependencies)

add_custom_command(TARGET external_dependencies
    POST_BUILD
    COMMAND ${CMAKE_COMMAND} ..
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

####################
# Igloo
####################
find_package(Igloo)
if(NOT DISABLE_IGLOO AND NOT IGLOO_FOUND)
    ExternalProject_Add(
        igloo
        INSTALL_DIR ${CMAKE_CURRENT_SOURCE_DIR}
        URL https://github.com/joakimkarlsson/igloo/archive/igloo.1.1.1.zip
        URL_MD5 a5c77fcea616f217dda7ad518cef253d
        UPDATE_COMMAND ""
        CMAKE_ARGS
          -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
          -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
          -DCMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}
        BUILD_COMMAND cmake --build <BINARY_DIR> --target igloo-tests
        INSTALL_COMMAND
          ${CMAKE_COMMAND} -E make_directory <INSTALL_DIR>/include/igloo &&
          ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/igloo <INSTALL_DIR>/include/igloo
    )

    add_dependencies(external_dependencies igloo)
endif(NOT DISABLE_IGLOO AND NOT IGLOO_FOUND)

####################
# CATCH
####################
find_package(Catch)
if(NOT DISABLE_CATCH AND NOT CATCH_FOUND)
    ExternalProject_Add(
        catch
        INSTALL_DIR ${CMAKE_CURRENT_SOURCE_DIR}
        URL https://github.com/philsquared/Catch/archive/master.zip
        UPDATE_COMMAND ""
        CONFIGURE_COMMAND ""
        BUILD_COMMAND ""
        INSTALL_COMMAND
          ${CMAKE_COMMAND} -E make_directory <INSTALL_DIR>/include/catch &&
          ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/single_include/catch.hpp <INSTALL_DIR>/include/catch/
    )

    add_dependencies(external_dependencies catch)
endif(NOT DISABLE_CATCH AND NOT CATCH_FOUND)

####################
# Google Mock
####################
find_package(GMock)
find_package(GTest)
if(NOT GMOCK_FOUND OR NOT GTEST_FOUND)
    ExternalProject_Add(
        googlemock
        INSTALL_DIR ${CMAKE_CURRENT_SOURCE_DIR}
        URL http://googlemock.googlecode.com/files/gmock-1.7.0.zip
        URL_MD5 073b984d8798ea1594f5e44d85b20d66
        UPDATE_COMMAND ""
        CMAKE_ARGS
          -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
          -DCMAKE_CXX_FLAGS=${CXX_FLAGS}
          -DCMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}
          -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
          -Dgtest_force_shared_crt=${MSVC}
          -DBUILD_SHARED_LIBS=OFF
        INSTALL_COMMAND
          ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/gtest/include <INSTALL_DIR>/include &&
          ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/include <INSTALL_DIR>/include &&
          ${CMAKE_COMMAND} -E copy <BINARY_DIR>/${LIB_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}gmock${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/ &&
          ${CMAKE_COMMAND} -E copy <BINARY_DIR>/gtest/${LIB_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}gtest${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/ &&
          ${CMAKE_COMMAND} -E copy <BINARY_DIR>/${LIB_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}gmock_main${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/  &&
          ${CMAKE_COMMAND} -E copy <BINARY_DIR>/gtest/${LIB_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}gtest_main${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/
    )

    # override GMock_LIBRARY_DIRS such that only the ones from external are used
    ExternalProject_Get_Property(googlemock INSTALL_DIR)
    set(GMOCK_LIBRARY_DIRS ${INSTALL_DIR})
    add_dependencies(external_dependencies googlemock)
endif(NOT GMOCK_FOUND OR NOT GTEST_FOUND)

####################
# Boost
####################

# Set boost minimal version in order to build cppspec and cucumber-cpp with the same library versions
set(BOOST_MIN_VERSION 1.55)
set(Boost_Version ${BOOST_MIN_VERSION}.0)
set(Boost_MD5 d6eef4b4cacb2183f2bf265a5a03a354)

find_package(Boost ${Boost_Version})
if(NOT Boost_FOUND)

    # cucumber-cpp and CppSpec needs filesystem, date_time, chrono, thread, system, regex and program_options
    # TODO: add your boost libraries here if you need one
    set(Boost_Components filesystem date_time chrono thread system regex program_options)
    string( REPLACE "." "_" Boost_Version_Underscore ${Boost_Version} )

    foreach(library ${Boost_Components})
      set(BOOST_LIBRARIES ${BOOST_LIBRARIES} --with-${library})
    endforeach(library)

    string(TOLOWER ${CMAKE_BUILD_TYPE} BOOST_VARIANT)
    set(BOOST_THREADING multi)
    set(BOOST_LAYOUT tagged)

    if(MSVC)
      set(BOOST_LAYOUT versioned)
    endif(MSVC)

    set(BOOST_TOOLSET)
    set(BOOST_TOOLSET_BUILD)

    # Use the same compiler for building boost as for your own project
    if(CMAKE_COMPILER_IS_GNUCXX AND WIN32)
      set(BOOST_TOOLSET "mingw")
      set(BOOST_TOOLSET_BUILD "toolset=gcc")
      set(BOOST_CXX_FLAGS "-std=c++11")
    elseif(CMAKE_COMPILER_IS_GNUCXX)
    # Determine the gcc version
      execute_process(COMMAND
        ${CMAKE_CXX_COMPILER} -dumpversion
        OUTPUT_VARIABLE
        GCC_VERSION
      )
      set(BOOST_TOOLSET "gcc")
      set(BOOST_TOOLSET_BUILD "toolset=gcc-${GCC_VERSION}")
      set(BOOST_CXX_FLAGS "-std=c++11")
      set(BOOST_LINK_FLAGS "")
    elseif(CMAKE_CXX_COMPILER MATCHES ".*clang")
      set(BOOST_TOOLSET "clang")
      set(BOOST_TOOLSET_BUILD "toolset=clang")
      set(BOOST_CXX_FLAGS "-std=c++11 -Wno-c99-extensions")
    elseif(MSVC)
      if (NOT BOOST_TOOLSET)
        set(BOOST_TOOLSET "msvc")
      endif(NOT BOOST_TOOLSET)
    endif(CMAKE_COMPILER_IS_GNUCXX AND WIN32)

    ExternalProject_Add(
        boost
        URL http://downloads.sourceforge.net/project/boost/boost/${Boost_Version}/boost_${Boost_Version_Underscore}.tar.bz2
        URL_MD5 ${Boost_MD5}
        INSTALL_DIR ${CMAKE_CURRENT_SOURCE_DIR}
        UPDATE_COMMAND ""
        CONFIGURE_COMMAND ./bootstrap${SCRIPT_SUFFIX} --with-toolset=${BOOST_TOOLSET} --prefix=<INSTALL_DIR>
        BUILD_COMMAND ./b2 install --prefix=<INSTALL_DIR>
                        ${BOOST_LIBRARIES}
                        -j8
                        --build-type=complete
                        variant=${BOOST_VARIANT}
                        link=shared,static
                        threading=${BOOST_THREADING}
                        --layout=${BOOST_LAYOUT}
                        cxxflags=${BOOST_CXX_FLAGS}
                        ${BOOST_TOOLSET_BUILD}
        BUILD_IN_SOURCE 1
        INSTALL_COMMAND ""
    )

    if(MSVC)
      string( REPLACE "_0" "" Boost_Version_Shorten ${Boost_Version_Underscore} )
      ExternalProject_Add_Step(
        boost MoveHeaders
        COMMAND move ${CMAKE_CURRENT_SOURCE_DIR}/include/boost-${Boost_Version_Shorten}/boost ${CMAKE_CURRENT_SOURCE_DIR}/include/boost
        DEPENDEES install
      )

      set(Boost_USE_STATIC_LIBS ON)
      set(Boost_USE_MULTITHREADED ON)
      set(Boost_USE_STATIC_RUNTIME OFF)
    endif(MSVC)

    # set boost cmake variables such that only the ones from external are used
    ExternalProject_Get_Property(boost INSTALL_DIR)
    set(BOOST_ROOT ${INSTALL_DIR})
    set(Boost_NO_SYSTEM_PATHS ON)

    get_directory_property(hasParent PARENT_DIRECTORY)
    if(hasParent)
        set(BOOST_ROOT ${INSTALL_DIR} PARENT_SCOPE)
        set(Boost_NO_SYSTEM_PATHS ON PARENT_SCOPE)
    endif(hasParent)
    add_dependencies(external_dependencies boost)
endif(NOT Boost_FOUND)

find_package(Boost ${BOOST_MIN_VERSION} COMPONENTS ${Boost_Components})

if(Boost_FOUND)
    set(CUKE_EXTERNAL_PROJ_DEPENDS)
    set(CUKE_DEPENDENCIES_INCLUDE_DIRS ${Boost_INCLUDE_DIRS})
    set(CUKE_DEPENDENCIES_LIBS_DIRS ${Boost_LIBRARY_DIRS})
    set(CUKE_DEPENDENCIES ${Boost_LIBRARIES} )
    set(CPPSPEC_EXTERNAL_PROJ_DEPENDS)
    set(CPPSPEC_DEPENDENCIES_INCLUDE_DIRS ${Boost_INCLUDE_DIRS})
    set(CPPSPEC_DEPENDENCIES_LIBS_DIRS ${Boost_LIBRARY_DIRS})
    set(CPPSPEC_DEPENDENCIES ${Boost_LIBRARIES} )
else(Boost_FOUND)
    set(CUKE_EXTERNAL_PROJ_DEPENDS boost)
    set(CPPSPEC_EXTERNAL_PROJ_DEPENDS boost)
endif(Boost_FOUND)

find_package(GTest)

if(GTEST_FOUND)
  set(CPPSPEC_DEPENDENCIES_INCLUDE_DIRS ${GTEST_INCLUDE_DIRS})
  set(CPPSPEC_DEPENDENCIES_LIBS_DIRS ${GTEST_LIBRARY_DIRS})
  set(CPPSPEC_DEPENDENCIES ${GTEST_LIBRARIES} )
  set(CUKE_DEPENDENCIES_INCLUDE_DIRS ${CUKE_DEPENDENCIES_INCLUDE_DIRS} ${GTEST_INCLUDE_DIRS})
  set(CUKE_DEPENDENCIES_LIBS_DIRS ${CUKE_DEPENDENCIES_LIBS_DIRS} ${GTEST_LIBRARY_DIRS})
  set(CUKE_DEPENDENCIES ${CUKE_DEPENDENCIES} ${GTEST_LIBRARIES})
else(GTEST_FOUND)
  set(CUKE_EXTERNAL_PROJ_DEPENDS ${CUKE_EXTERNAL_PROJ_DEPENDS} googlemock)
  set(CPPSPEC_EXTERNAL_PROJ_DEPENDS ${CPPSPEC_EXTERNAL_PROJ_DEPENDS} googlemock)
endif(GTEST_FOUND)

if(UNIX)
    if(NOT DISABLE_CPPSPEC)
        find_package(CppSpec)
        if(NOT CPPSPEC_FOUND)
            ####################
            # CppSpec
            ####################
            ExternalProject_Add(
                cppspec
                INSTALL_DIR ${CMAKE_CURRENT_SOURCE_DIR}
                GIT_REPOSITORY https://github.com/meshell/cppspec.git
                GIT_TAG cmake_fix
                # URL https://github.com/tpuronen/cppspec/archive/release-0.5.tar.gz
                # URL_MD5 88e462b4416aa64463a9cd7fda105708
                DEPENDS ${CPPSPEC_EXTERNAL_PROJ_DEPENDS}
                CMAKE_ARGS
                  -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
                  -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
                  -DCMAKE_CXX_FLAGS='-Wno-unused-local-typedefs'
                  -DCMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}
                BUILD_COMMAND cmake --build <BINARY_DIR> --target CppSpec
                UPDATE_COMMAND ""
                INSTALL_COMMAND
                  ${CMAKE_COMMAND} -E make_directory <INSTALL_DIR>/include/CppSpec &&
                  ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/include <INSTALL_DIR>/include/CppSpec &&
                  ${CMAKE_COMMAND} -E copy <BINARY_DIR>/lib/${CMAKE_SHARED_LIBRARY_PREFIX}CppSpec${CMAKE_SHARED_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/
             )
            add_dependencies(external_dependencies cppspec)
        endif(NOT CPPSPEC_FOUND)

        find_package(CppSpec)

        if(CPPSPEC_FOUND)
          set(CUKE_DEPENDENCIES_INCLUDE_DIRS ${CUKE_DEPENDENCIES_INCLUDE_DIRS} ${CPPSPEC_INCLUDE_DIRS})
          set(CUKE_DEPENDENCIES ${CUKE_DEPENDENCIES} ${CPPSPEC_LIBRARIES})
        else(CPPSPEC_FOUND)
          set(CUKE_EXTERNAL_PROJ_DEPENDS ${CUKE_EXTERNAL_PROJ_DEPENDS} cppspec)
        endif(CPPSPEC_FOUND)
    endif(NOT DISABLE_CPPSPEC)
else(UNIX)  
    set(CPPSPEC_ROOT ${CMAKE_CURRENT_SOURCE_DIR})
endif(UNIX)

####################
# Cucumber-cpp
####################
find_package(Cuke)

if(NOT CUKE_FOUND)
    ExternalProject_Add(
        cucumber-cpp
        INSTALL_DIR ${CMAKE_CURRENT_SOURCE_DIR}
        GIT_REPOSITORY https://github.com/meshell/cucumber-cpp
        GIT_TAG gcc48
        #  URL https://github.com/cucumber/cucumber-cpp/archive/v0.3.tar.gz
        #  URL_MD5 c6498c974ddca7a87e07097d0172a1df
        DEPENDS ${CUKE_EXTERNAL_PROJ_DEPENDS}
        CMAKE_ARGS
          -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
          -DCMAKE_CXX_FLAGS=${CXX_FLAGS}
          -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
          -DCMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}
          -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
          -DCUKE_USE_STATIC_BOOST=ON
          -DCUKE_DISABLE_BOOST_TEST=ON
          -DCUKE_DISABLE_GTEST=OFF
          -DCUKE_DISABLE_CPPSPEC=OFF
          -DCUKE_ENABLE_EXAMPLES=OFF
          -DBUILD_SHARED_LIBS=ON
        BUILD_COMMAND cmake --build <BINARY_DIR> --target cucumber-cpp
        UPDATE_COMMAND ""
        INSTALL_COMMAND
          ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/include <INSTALL_DIR>/include &&
          ${CMAKE_COMMAND} -E copy <BINARY_DIR>/src/${LIB_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}cucumber-cpp${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/
    )
    add_dependencies(external_dependencies cucumber-cpp)
endif(NOT CUKE_FOUND)
