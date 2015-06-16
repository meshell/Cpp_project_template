### versions
set(CPACK_PACKAGE_VERSION_MAJOR "${PROJECT_VERSION_MAJOR}")
set(CPACK_PACKAGE_VERSION_MINOR "${PROJECT_VERSION_MINOR}")
set(CPACK_PACKAGE_VERSION_PATCH "${PROJECT_VERSION_PATCH}")
set(CPACK_PACKAGE_VERSION "${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH}")

### general settings
set(CPACK_PACKAGE_NAME "${APPLICATION_NAME}")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "C++ Project Template based on CMake.")
set(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_SOURCE_DIR}/README.md")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/LICENSE")
set(CPACK_PACKAGE_VENDOR "Michel Estermann")

set(CPACK_PACKAGE_INSTALL_DIRECTORY "Cpp CMake Project Template")
set(CPACK_OUTPUT_FILE_PREFIX "../install")

set(CPACK_COMPONENTS_ALL main library headers doc)

set(CPACK_COMPONENT_MAIN_GROUP "Runtime")
set(CPACK_COMPONENT_DOC_GROUP "Runtime")
set(CPACK_COMPONENT_LIBRARY_GROUP "Development")
set(CPACK_COMPONENT_HEADERS_GROUP "Development")
set(CPACK_COMPONENT_GROUP_DEVELOPMENT_DESCRIPTION
	 "All of the stuff you'll never need to develop software"
 )
	
 set(CPACK_COMPONENT_GROUP_RUNTIME_DESCRIPTION
	 "The main application"
 )

if(WIN32 AND NOT UNIX)
  ### nsis generator
  set(CPACK_GENERATOR "NSIS")  
  set(CPACK_NSIS_DISPLAY_NAME "${APPLICATION_NAME}")
  set(CPACK_NSIS_COMPRESSOR "/SOLID zlib")   

  set(CPACK_NSIS_CONTACT "estermann.michel@gmail.com")
  set(CPACK_NSIS_HELP_LINK "https://github.com/meshell/${PROJECT_NAME}")
  set(CPACK_NSIS_URL_INFO_ABOUT "https://github.com/meshell/${PROJECT_NAME}")
  
  set(CPACK_NSIS_CREATE_ICONS "
    SetOutPath \\\"$INSTDIR\\\\bin\\\"
    CreateShortCut \\\"$SMPROGRAMS\\\\$STARTMENU_FOLDER\\\\C++Template.lnk\\\" \\\"$INSTDIR\\\\doc\\\\html\\\\index.html\\\"
    CreateShortCut \\\"$SMPROGRAMS\\\\$STARTMENU_FOLDER\\\\License.lnk\\\" \\\"$INSTDIR\\\\doc\\\\LICENSE.txt\\\"
    CreateShortCut \\\"$SMPROGRAMS\\\\$STARTMENU_FOLDER\\\\README.lnk\\\" \\\"$INSTDIR\\\\doc\\\\README.md\\\"
  ")
  set(CPACK_NSIS_DELETE_ICONS "
    Delete \\\"$SMPROGRAMS\\\\$MUI_TEMP\\\\C++Template.lnk\\\"
    Delete \\\"$SMPROGRAMS\\\\$MUI_TEMP\\\\License.lnk\\\"
    Delete \\\"$SMPROGRAMS\\\\$MUI_TEMP\\\\README.lnk\\\"
  ")
  
  set(CPACK_NSIS_MENU_LINKS "doc/html/index.html" "Documentation")

else(WIN32 AND NOT UNIX)
	# Determine current architecture
	macro(dpkg_arch VAR_NAME)
	  find_program(DPKG_PROGRAM dpkg DOC "dpkg program of Debian-based systems")
		if (DPKG_PROGRAM)
		  execute_process(
			  COMMAND ${DPKG_PROGRAM} --print-architecture
				OUTPUT_VARIABLE ${VAR_NAME}
				OUTPUT_STRIP_TRAILING_WHITESPACE
			)
		endif(DPKG_PROGRAM)
	endmacro(dpkg_arch)
	
	# DEB package config
        string(TOLOWER ${PROJECT_NAME} LOWER_CASE_PROJECT_NAME)
	set(CPACK_DEBIAN_PACKAGE_NAME ${LOWER_CASE_PROJECT_NAME})
	set(CPACK_DEBIAN_PACKAGE_MAINTAINER "Michel Estermann <estermann.michel@gmail.com>")
        set(CPACK_DEBIAN_PACKAGE_HOMEPAGE "https://github.com/meshell/${PROJECT_NAME}")
	#set(CPACK_DEBIAN_PACKAGE_SECTION "")
	#set(CPACK_DEBIAN_PACKAGE_DEPENDS "")
	set(CPACK_GENERATOR "DEB")
	set(CPACK_SET_DESTDIR true)
	set(CPACK_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX})
					
	dpkg_arch(CPACK_DEBIAN_PACKAGE_ARCHITECTURE)
	if (CPACK_DEBIAN_PACKAGE_ARCHITECTURE)
	  set(CPACK_PACKAGE_FILE_NAME ${CPACK_DEBIAN_PACKAGE_NAME}_${CPACK_PACKAGE_VERSION}_${CPACK_DEBIAN_PACKAGE_ARCHITECTURE})
	else (CPACK_DEBIAN_PACKAGE_ARCHITECTURE)
	 set(CPACK_PACKAGE_FILE_NAME ${CPACK_DEBIAN_PACKAGE_NAME}_${CPACK_PACKAGE_VERSION}_${CMAKE_SYSTEM_NAME})
  endif (CPACK_DEBIAN_PACKAGE_ARCHITECTURE)
endif (WIN32 AND NOT UNIX)


include(CPack)
include(InstallRequiredSystemLibraries)
