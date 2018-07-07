include(CMakeParseArguments)

# Provides an option that the user can optionally select.
# Can accept condition to control when option is available for user.
# Usage:
#   option(<option_variable> "help string describing the option" <initial value or boolean expression> [IF <condition>])
macro(EASY_MACE_OPTION variable description value)
  set(__value ${value})
  set(__condition "")
  set(__varname "__value")
  foreach(arg ${ARGN})
    if(arg STREQUAL "IF" OR arg STREQUAL "if")
      set(__varname "__condition")
    else()
      list(APPEND ${__varname} ${arg})
    endif()
  endforeach()
  unset(__varname)
  if(__condition STREQUAL "")
    set(__condition 2 GREATER 1)
  endif()

  if(${__condition})
    if(__value MATCHES ";")
      if(${__value})
        option(${variable} "${description}" ON)
      else()
        option(${variable} "${description}" OFF)
      endif()
    elseif(DEFINED ${__value})
      if(${__value})
        option(${variable} "${description}" ON)
      else()
        option(${variable} "${description}" OFF)
      endif()
    else()
      option(${variable} "${description}" ${__value})
    endif()
  else()
    unset(${variable} CACHE)
  endif()
  unset(__condition)
  unset(__value)
endmacro()

macro(easy_mace_subdirlist result curdir)
  file(GLOB children ${curdir}/*)
  set(dirlist "")
  foreach(child ${children})
    if(IS_DIRECTORY ${child})
      list(APPEND dirlist ${child})
    endif()
  endforeach()
  set(${result} ${dirlist})
endmacro()

macro(easy_mace_buildlibrary name type)
  set(sources "")
  set(dependencies "")
  set(mode "unknown")
  foreach(var ${ARGN})
    if(var STREQUAL "SOURCES")
      set(mode "SOURCES")
    elseif(var STREQUAL "DEPENDENCIES")
      set(mode "DEPENDENCIES")
    else()
      if(mode STREQUAL "SOURCES")
        list(APPEND sources ${var})
      elseif(mode STREQUAL "DEPENDENCIES")
        list(APPEND dependencies ${var})
      endif()
    endif()
  endforeach()
  add_library(${name} ${type} ${sources})
  if(APPLE)
    target_compile_options(${name} PUBLIC "-fobjc-arc")
  endif()
  target_link_libraries(${name} ${dependencies})
  
  install(TARGETS ${name} 
          CONFIGURATIONS
          Debug
          RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}/bin/Debug
          LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/Debug
          ARCHIVE DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/Debug)
  install(TARGETS ${name} 
          CONFIGURATIONS
          Release
          RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}/bin/Release
          LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/Release
          ARCHIVE DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/Release)
endmacro()

macro(easy_mace_add_framework fwname appname)
  if(NOT (${fwname} STREQUAL "opencv2"))
    set(FRAMEWORK_${fwname} "FRAMEWORK_${fwname}-NOTFOUND")
  endif()
  if(BUILD_IOS_FRAMEWORK)
    set(FRAMEWORK_PATHS "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/System/Library")
  else()
    set(FRAMEWORK_PATHS "${CMAKE_OSX_SYSROOT}/System/Library")
  endif()
  find_library(FRAMEWORK_${fwname}
               NAMES ${fwname}
               PATHS ${FRAMEWORK_PATHS}
               PATH_SUFFIXES Frameworks
               NO_DEFAULT_PATH)
  if(${FRAMEWORK_${fwname}} STREQUAL FRAMEWORK_${fwname}-NOTFOUND)
    message(FATAL_ERROR "Framework ${fwname} not found")
  else()
    target_link_libraries(${appname} "${FRAMEWORK_${fwname}}")
    message("Framework ${fwname} found at ${FRAMEWORK_${fwname}}")
  endif()
endmacro()

macro(easy_mace_set_framework libname_)
set_target_properties(${libname_} PROPERTIES
                      FRAMEWORK TRUE
                      SOVERSION "1"
                      VERSION "1"
                      XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "iPhone Developer"
                      XCODE_ATTRIBUTE_DYLIB_INSTALL_NAME_BASE "@rpath"
                      XCODE_ATTRIBUTE_INSTALL_PATH "/Framework"
                      XCODE_ATTRIBUTE_INFOPLIST_FILE "apple_framework/Info.plist"
                      XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER "easy_mace2.${libname_}"
                      XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET "8.0"
                      XCODE_ATTRIBUTE_FRAMEWORK_VERSION "A"
                      XCODE_ATTRIBUTE_CURRENT_PROJECT_VERSION "1"
                      XCODE_ATTRIBUTE_BITCODE_GENERATION_MODE "bitcode")
endmacro()

macro(easy_mace_make_group FILES_LIST)
  foreach(FILE ${FILES_LIST})
    #convert source file to absolute
    get_filename_component(ABSOLUTE_PATH "${FILE}" ABSOLUTE)
    # Get the directory of the absolute source file
    get_filename_component(PARENT_DIR "${ABSOLUTE_PATH}" DIRECTORY)
    # Remove common directory prefix to make the group
    string(REPLACE "${CMAKE_CURRENT_SOURCE_DIR}" "" GROUP "${PARENT_DIR}")
    # Make sure we are using windows slashes
    string(REPLACE "/" "\\" GROUP "${GROUP}")
    # Group into "Source Files" and "Header Files"
    if ("${FILE}" MATCHES ".*\\.cpp")
      set(GROUP "Source Files${GROUP}")
    elseif("${FILE}" MATCHES ".*\\.h")
      set(GROUP "Header Files${GROUP}")
    endif()
    source_group("${GROUP}" FILES "${FILE}")
  endforeach()
endmacro()

macro(easy_mace_buildapp name)
  set(sources "")
  set(dependencies "")
  set(mode "unknown")
  foreach(var ${ARGN})
    if(var STREQUAL "SOURCES")
      set(mode "SOURCES")
    elseif(var STREQUAL "DEPENDENCIES")
      set(mode "DEPENDENCIES")
    else()
      if(mode STREQUAL "SOURCES")
        list(APPEND sources ${var})
      elseif(mode STREQUAL "DEPENDENCIES")
        list(APPEND dependencies ${var})
      endif()
    endif()
  endforeach()
  add_executable(${name} ${sources})
  if(APPLE)
    target_compile_options(${name} PUBLIC "-fobjc-arc")
  endif()
  target_link_libraries(${name} ${dependencies})
endmacro()

macro(easy_mace_build_test name_ headers_ sources_ deps_)
  easy_mace_buildapp(${name_} SOURCES ${headers_} ${sources_} DEPENDENCIES ${deps_})
endmacro()