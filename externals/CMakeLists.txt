# CMake file to build the external dependencies
cmake_minimum_required(VERSION 3.2 FATAL_ERROR)

option(DISABLE_CPPSPEC "Do not use CppSpec" ${WIN32})
option(DISABLE_IGLOO "Do not use Igloo testing framework" FALSE)
option(DISABLE_CATCH "Do not use CATCH testing framework" FALSE)
option(USE_STATIC_BOOST "Statically link Boost" ${WIN32})
option(USE_STATIC_GTEST "Statically link GTest" TRUE)
set(GMOCK_VERSION "1.7.0" CACHE STRING "Define googlemock version")
set(IGLOO_VERSION "1.1.1" CACHE STRING "Define igloo testing framework version")
set(CATCH_VERSION "1.5.0" CACHE STRING "Define Catch version")
set(CUKE_VERSION "0.3.1" CACHE STRING "Define cucumber-cpp version")
set(BOOST_VERSION "1.61.0" CACHE STRING "Define Boost version")

# set the path to the additional cmake modules
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../cmake/modules)

# set default built type to Debug
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Debug)
endif(NOT CMAKE_BUILD_TYPE)

include(ExternalProject)

# create output directories
if(NOT EXT_INSTALL_DIR)
  set(EXT_INSTALL_DIR ${CMAKE_CURRENT_SOURCE_DIR})
  set(EXT_INSTALL_INCLUDE_DIR ${EXT_INSTALL_DIR}/include)
  set(EXT_INSTALL_LIB_DIR ${EXT_INSTALL_DIR}/lib)

  set(CMAKE_INCLUDE_PATH ${EXT_INSTALL_INCLUDE_DIR})

  set(CMAKE_LIBRARY_PATH ${EXT_INSTALL_LIB_DIR})

  file(MAKE_DIRECTORY
      ${EXT_INSTALL_DIR}
      ${EXT_INSTALL_INCLUDE_DIR}
      ${EXT_INSTALL_LIB_DIR}
      )

  get_directory_property(hasParent PARENT_DIRECTORY)
  if(hasParent)
    set(CMAKE_INCLUDE_PATH ${EXT_INSTALL_INCLUDE_DIR} PARENT_SCOPE)
    set(CMAKE_LIBRARY_PATH ${EXT_INSTALL_LIB_DIR} PARENT_SCOPE)
  endif(hasParent)
endif()



set(CMAKE_PREFIX_PATH ${CMAKE_CURRENT_SOURCE_DIR})
if(MSVC)
  set(LIB_DIR ${CMAKE_BUILD_TYPE})
else(MSVC)
  set(LIB_DIR "")
endif(MSVC)

if(WIN32)
  set(SCRIPT_SUFFIX .bat)
  set(EXE_SUFFIX .exe)
else(WIN32)
  set(SCRIPT_SUFFIX .sh)
  set(EXE_SUFFIX "")
endif(WIN32)

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
  ExternalProject_Add(igloo
      INSTALL_DIR ${EXT_INSTALL_DIR}
      URL https://github.com/joakimkarlsson/igloo/archive/igloo.${IGLOO_VERSION}.tar.gz
      LOG_DOWNLOAD ON
      LOG_CONFIGURE ON
      LOG_BUILD ON
      UPDATE_COMMAND ""
      CONFIGURE_COMMAND ""
      BUILD_COMMAND ""
      INSTALL_COMMAND
        ${CMAKE_COMMAND} -E make_directory ${EXT_INSTALL_INCLUDE_DIR}/igloo &&
        ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/igloo ${EXT_INSTALL_INCLUDE_DIR}/igloo
  )

  add_dependencies(external_dependencies igloo)
endif(NOT DISABLE_IGLOO AND NOT IGLOO_FOUND)

####################
# CATCH
####################
find_package(Catch)
if(NOT DISABLE_CATCH AND NOT CATCH_FOUND)
  ExternalProject_Add(catch
      INSTALL_DIR ${CMAKE_CURRENT_SOURCE_DIR}
      URL https://github.com/philsquared/Catch/archive/V${CATCH_VERSION}.tar.gz
      URL_MD5 d18fc213fb5cf662ce507b6fb549d5f6
      LOG_DOWNLOAD ON
      LOG_CONFIGURE ON
      LOG_BUILD ON
      UPDATE_COMMAND ""
      CONFIGURE_COMMAND ""
      BUILD_COMMAND ""
      INSTALL_COMMAND
        ${CMAKE_COMMAND} -E make_directory ${EXT_INSTALL_INCLUDE_DIR}/catch &&
        ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/single_include/catch.hpp ${EXT_INSTALL_INCLUDE_DIR}/catch/
  )

  add_dependencies(external_dependencies catch)
endif(NOT DISABLE_CATCH AND NOT CATCH_FOUND)

####################
# Google Mock
####################
find_package(GMock)
find_package(GTest)
if(NOT GMOCK_FOUND OR NOT GTEST_FOUND)
  if(USE_STATIC_GTEST)
    set(GTEST_CMAKE_ARGS -Dgtest_force_shared_crt:BOOL=ON -DBUILD_SHARED_LIBS=OFF)
    set(LIBRARY_PREFIX ${CMAKE_STATIC_LIBRARY_PREFIX})
    set(LIBRARY_SUFFIX ${CMAKE_STATIC_LIBRARY_SUFFIX})
  else(USE_STATIC_GTEST)
    set(GTEST_CMAKE_ARGS -DBUILD_SHARED_LIBS=ON)
    set(LIBRARY_PREFIX ${CMAKE_SHARED_LIBRARY_PREFIX})
    set(LIBRARY_SUFFIX ${CMAKE_SHARED_LIBRARY_SUFFIX})
  endif(USE_STATIC_GTEST)


  if("${GMOCK_VERSION}" STREQUAL "1.6.0" OR "${GMOCK_VERSION}" STREQUAL "1.7.0")
    set(GMOCK_SRC_ROOT "${CMAKE_CURRENT_BINARY_DIR}/googlemock")

    ExternalProject_Add(gtest
        INSTALL_DIR ${CMAKE_CURRENT_SOURCE_DIR}
        GIT_REPOSITORY "https://github.com/google/googletest.git"
        GIT_TAG "release-${GMOCK_VERSION}"
        PREFIX ${GMOCK_SRC_ROOT}
        LOG_DOWNLOAD ON
        LOG_CONFIGURE ON
        LOG_BUILD ON
        UPDATE_COMMAND ""
        CMAKE_ARGS
          -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
          -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
          -Dgtest_disable_pthreads=${MINGW}
          ${GTEST_CMAKE_ARGS}
        INSTALL_COMMAND
          ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/include ${EXT_INSTALL_INCLUDE_DIR} &&
          ${CMAKE_COMMAND} -E copy <BINARY_DIR>/${LIB_DIR}/${LIBRARY_PREFIX}gtest${LIBRARY_SUFFIX} ${EXT_INSTALL_LIB_DIR} &&
          ${CMAKE_COMMAND} -E copy <BINARY_DIR>/${LIB_DIR}/${LIBRARY_PREFIX}gtest_main${LIBRARY_SUFFIX} ${EXT_INSTALL_LIB_DIR}
    )

    ExternalProject_Add(googlemock
        INSTALL_DIR ${CMAKE_CURRENT_SOURCE_DIR}
        GIT_REPOSITORY "https://github.com/google/googlemock.git"
        GIT_TAG "release-${GMOCK_VERSION}"
        PREFIX ${GMOCK_SRC_ROOT}
        LOG_DOWNLOAD ON
        LOG_CONFIGURE ON
        LOG_BUILD ON
        UPDATE_COMMAND ""
        CMAKE_ARGS
          -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
          -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
          -Dgtest_disable_pthreads=${MINGW}
          ${GTEST_CMAKE_ARGS}
        DEPENDS gtest
        INSTALL_COMMAND
          ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/include ${EXT_INSTALL_INCLUDE_DIR} &&
          ${CMAKE_COMMAND} -E copy <BINARY_DIR>/${LIB_DIR}/${LIBRARY_PREFIX}gmock${LIBRARY_SUFFIX} ${EXT_INSTALL_LIB_DIR} &&
          ${CMAKE_COMMAND} -E copy <BINARY_DIR>/${LIB_DIR}/${LIBRARY_PREFIX}gmock_main${LIBRARY_SUFFIX} ${EXT_INSTALL_LIB_DIR}
    )

    # override GMOCK_LIBRARY_DIRS such that only the ones from external are used
    set(GMOCK_ROOT ${EXT_INSTALL_DIR})
    set(GMOCK_LIBRARY_DIRS ${EXT_INSTALL_LIB_DIR})
    add_dependencies(external_dependencies googlemock)

    # override GTEST_LIBRARY_DIRS such that only the ones from external are used
    set(GTEST_ROOT ${EXT_INSTALL_DIR})
    set(GTEST_LIBRARY_DIRS ${EXT_INSTALL_LIB_DIR})
    add_dependencies(external_dependencies gtest)
  else() #1.8.0
    ExternalProject_Add(googlemock
        INSTALL_DIR ${CMAKE_CURRENT_SOURCE_DIR}
        GIT_REPOSITORY "https://github.com/google/googletest.git"
        GIT_TAG "release-${GMOCK_VER}"
        URL https://github.com/google/googletest/archive/release-${GMOCK_VERSION}.tar.gz
        LOG_DOWNLOAD ON
        LOG_CONFIGURE ON
        LOG_BUILD ON
        UPDATE_COMMAND ""
        CMAKE_ARGS
          -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
          -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
          -Dgtest_disable_pthreads=${MINGW}
          -DBUILD_GTEST=ON
          ${GTEST_CMAKE_ARGS}
        INSTALL_COMMAND
          ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/googlemock/include ${EXT_INSTALL_INCLUDE_DIR} &&
          ${CMAKE_COMMAND} -E copy <BINARY_DIR>/googlemock/${LIB_DIR}/${LIBRARY_PREFIX}gmock${LIBRARY_SUFFIX} ${EXT_INSTALL_LIB_DIR} &&
          ${CMAKE_COMMAND} -E copy <BINARY_DIR>/googlemock/${LIB_DIR}/${LIBRARY_PREFIX}gmock_main${LIBRARY_SUFFIX} ${EXT_INSTALL_LIB_DIR}
    )

    # override GMOCK_LIBRARY_DIRS such that only the ones from external are used
    set(GMOCK_ROOT ${EXT_INSTALL_DIR})
    set(GMOCK_LIBRARY_DIRS ${EXT_INSTALL_LIB_DIR})
    add_dependencies(external_dependencies googlemock)
  endif()
endif(NOT GMOCK_FOUND OR NOT GTEST_FOUND)

####################
# Boost
####################

# cucumber-cpp needs date_time, thread, system, regex and program_options
set(Boost_Components thread system regex date_time program_options)

# TODO: add your boost libraries here if you need one
# set(Boost_Components ${Boost_Components} program_options)

if(NOT DISABLE_CPPSPEC)
  # cppspec needs additionally filesystem and chrono
  set(Boost_Components ${Boost_Components} filesystem chrono)
endif(NOT DISABLE_CPPSPEC)

find_package(Boost COMPONENTS ${Boost_Components})

if(NOT Boost_FOUND)

  string( REPLACE "." "_" Boost_Version_Underscore ${BOOST_VERSION} )

  foreach(library ${Boost_Components})
    set(BOOST_LIBRARIES ${BOOST_LIBRARIES} --with-${library})
  endforeach(library)

  string(TOLOWER ${CMAKE_BUILD_TYPE} BOOST_VARIANT)
  set(BOOST_THREADING multi)

  set(BOOST_LAYOUT tagged)

  set(BOOST_TOOLSET)
  set(BOOST_TOOLSET_BUILD)

  if(USE_STATIC_BOOST)
    set(BOOST_LINK "static")
  else(USE_STATIC_BOOST)
    set(BOOST_LINK "shared,static")
  endif(USE_STATIC_BOOST)

  if(MSVC12)
    set(BOOST_TOOLSET_BUILD "toolset=msvc-12.0")
  elseif(MSVC14)
    set(BOOST_TOOLSET_BUILD "toolset=msvc-14.0")
  endif(MSVC12)

  # Use the same compiler for building boost as for your own project
  if(CMAKE_COMPILER_IS_GNUCXX AND WIN32)
    set(BOOST_TOOLSET "mingw")
    set(BOOST_TOOLSET_BUILD "toolset=gcc")
    set(BOOST_CXX_FLAGS "-std=c++11")
  elseif(CMAKE_COMPILER_IS_GNUCXX)
    set(BOOST_TOOLSET "gcc")
    set(BOOST_TOOLSET_BUILD "toolset=gcc")
    set(BOOST_CXX_FLAGS "cxxflags='-std=c++11'")
    set(BOOST_LINK_FLAGS "")
  elseif(CMAKE_COMPILER_IS_CLANGCXX)
    set(BOOST_TOOLSET "clang")
    set(BOOST_TOOLSET_BUILD "toolset=clang")
    set(BOOST_CXX_FLAGS "cxxflags='-std=c++11 -Wno-c99-extensions'")
  elseif(MSVC)
    set(BOOST_TOOLSET "msvc")
    set(BOOST_LAYOUT versioned)
  endif(CMAKE_COMPILER_IS_GNUCXX AND WIN32)

  if(CMAKE_CL_64)
    set(BOOST_TOOLSET_ADDRESSMODEL "address-model=64")
  endif(CMAKE_CL_64)

  ExternalProject_Add(boost
      URL http://downloads.sourceforge.net/project/boost/boost/${BOOST_VERSION}/boost_${Boost_Version_Underscore}.tar.bz2
      LOG_DOWNLOAD ON
      LOG_CONFIGURE ON
      LOG_BUILD ON
      INSTALL_DIR ${EXT_INSTALL_DIR}
      UPDATE_COMMAND ""
      CONFIGURE_COMMAND
        <SOURCE_DIR>/bootstrap${SCRIPT_SUFFIX} --with-toolset=${BOOST_TOOLSET} --prefix=<INSTALL_DIR>
      BUILD_COMMAND
        <SOURCE_DIR>/b2${EXE_SUFFIX} install --prefix=<INSTALL_DIR>
        ${BOOST_LIBRARIES}
        -j8
        --build-type=complete
        variant=${BOOST_VARIANT}
        link=${BOOST_LINK}
        threading=${BOOST_THREADING}
        --layout=${BOOST_LAYOUT}
        ${BOOST_CXX_FLAGS}
        ${BOOST_TOOLSET_BUILD}
        ${BOOST_TOOLSET_ADDRESSMODEL}
      BUILD_IN_SOURCE 1
      INSTALL_COMMAND ""
  )

  if(MSVC)
    string( REPLACE "_0" "" Boost_Version_Shorten ${Boost_Version_Underscore} )
    ExternalProject_Add_Step(boost MoveHeaders
        COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/include/boost-${Boost_Version_Shorten}/boost ${EXT_INSTALL_INCLUDE_DIR}/boost
        COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_CURRENT_SOURCE_DIR}/include/boost-${Boost_Version_Shorten}
        COMMENT "Move boost headers..."
        DEPENDEES install
    )
  endif(MSVC)

  if(MINGW)
    ExternalProject_Add_Step(boost FixBoostProjectConfig
        COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/fix_boost_project-config_for_mingw.bat <BINARY_DIR>
        COMMAND ${CMAKE_COMMAND} -E chdir <BINARY_DIR> fix_boost_project-config_for_mingw.bat project-config.jam
        COMMENT "Fix boost project-config.jam file for MinGW..."
        DEPENDEES configure
        DEPENDERS build
    )
  endif(MINGW)

  if(WIN32)
    set(Boost_USE_MULTITHREADED ON)
    set(Boost_USE_STATIC_RUNTIME OFF)
  endif(WIN32)


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

find_package(Boost COMPONENTS ${Boost_Components})

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

if(NOT DISABLE_CPPSPEC)
  find_package(CppSpec)
  if(NOT CPPSPEC_FOUND)
    ####################
    # CppSpec
    ####################
    ExternalProject_Add(cppspec
        INSTALL_DIR ${EXT_INSTALL_DIR}
        GIT_REPOSITORY https://github.com/meshell/cppspec.git
        GIT_TAG cmake_fix
    # URL https://github.com/tpuronen/cppspec/archive/release-0.5.tar.gz
    # URL_MD5 88e462b4416aa64463a9cd7fda105708
        LOG_DOWNLOAD ON
        LOG_CONFIGURE ON
        LOG_BUILD ON
        DEPENDS ${CPPSPEC_EXTERNAL_PROJ_DEPENDS}
        CMAKE_ARGS
          -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
          -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
          -DCMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}
        BUILD_COMMAND
          cmake --build <BINARY_DIR> --target CppSpec --config ${CMAKE_BUILD_TYPE}
        UPDATE_COMMAND ""
        INSTALL_COMMAND
          ${CMAKE_COMMAND} -E make_directory <INSTALL_DIR>/include/CppSpec &&
          ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/include <INSTALL_DIR>/include/CppSpec &&
          ${CMAKE_COMMAND} -E copy <BINARY_DIR>/lib/${CMAKE_SHARED_LIBRARY_PREFIX}CppSpec${CMAKE_SHARED_LIBRARY_SUFFIX} ${EXT_INSTALL_LIB_DIR}/
    )
    add_dependencies(external_dependencies cppspec)
  endif(NOT CPPSPEC_FOUND)
endif(NOT DISABLE_CPPSPEC)

####################
# Cucumber-cpp
####################
find_package(Cuke)

if(NOT CUKE_FOUND)
  ExternalProject_Add(cucumber-cpp
      INSTALL_DIR ${EXT_INSTALL_DIR}
      GIT_REPOSITORY https://github.com/meshell/cucumber-cpp
      GIT_TAG GTest_download
#      URL https://github.com/cucumber/cucumber-cpp/archive/v${CUKE_VERSION}.tar.gz
      LOG_DOWNLOAD ON
      LOG_CONFIGURE ON
      LOG_BUILD ON
      DEPENDS ${CUKE_EXTERNAL_PROJ_DEPENDS}
      CMAKE_ARGS
        -DCMAKE_INCLUDE_PATH=${CMAKE_INCLUDE_PATH}
        -DCMAKE_LIBRARY_PATH=${CMAKE_LIBRARY_PATH}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
        -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
        -DCUKE_USE_STATIC_BOOST=${USE_STATIC_BOOST}
        -DCUKE_DISABLE_BOOST_TEST=ON
        -DCUKE_DISABLE_GTEST=OFF
        -DCUKE_ENABLE_EXAMPLES=OFF
        -DBUILD_SHARED_LIBS=ON
        -DCUKE_DISABLE_UNIT_TESTS=ON
        -DCUKE_DISABLE_E2E_TESTS=ON
      BUILD_COMMAND
        cmake --build <BINARY_DIR> --target cucumber-cpp --config ${CMAKE_BUILD_TYPE}
      UPDATE_COMMAND ""
      INSTALL_COMMAND
        ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/include ${EXT_INSTALL_INCLUDE_DIR} &&
        ${CMAKE_COMMAND} -E copy <BINARY_DIR>/src/${LIB_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}cucumber-cpp${CMAKE_STATIC_LIBRARY_SUFFIX} ${EXT_INSTALL_LIB_DIR}
  )
  add_dependencies(external_dependencies cucumber-cpp)
endif(NOT CUKE_FOUND)
