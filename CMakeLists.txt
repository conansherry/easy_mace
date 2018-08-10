# ----------------------------------------------------------------------------
#  Root CMake file for easy mace
#
#  author: conansherry
# ----------------------------------------------------------------------------

include(cmake/EasyMaceMinDepVersions.cmake)

cmake_minimum_required(VERSION "${MIN_VER_CMAKE}" FATAL_ERROR)

include(cmake/EasyMaceCmakeUtils.cmake)

if(NOT CMAKE_TOOLCHAIN_FILE)
    set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install" CACHE PATH "Installation Directory")
else(NOT CMAKE_TOOLCHAIN_FILE)
  #Android: set output folder to ${CMAKE_BINARY_DIR}
  set(LIBRARY_OUTPUT_PATH_ROOT ${CMAKE_BINARY_DIR} CACHE PATH "root for library output, set this to change where android libs are compiled to")
  # any crosscompiling
  set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install" CACHE PATH "Installation Directory")
endif(NOT CMAKE_TOOLCHAIN_FILE)

if(NOT CMAKE_DEBUG_POSTFIX)
  set(CMAKE_DEBUG_POSTFIX _d)
endif()

# BEGIN OPTION

EASY_MACE_OPTION(USE_NEON                     "-DMACE_ENABLE_NEON"                 OFF)
EASY_MACE_OPTION(USE_OPENCL                   "-DMACE_ENABLE_OPENCL"               OFF)
#EASY_MACE_OPTION(BUILD_SHARED_LIBRARIES       "Build shared library"               OFF)
EASY_MACE_OPTION(BUILD_IOS_FRAMEWORK          "Build ios framework"                OFF)
EASY_MACE_OPTION(BUILD_TESTS                  "Build tests application"            OFF)
EASY_MACE_OPTION(DEBUG_OPENCL                 "Debug opencl"                       OFF)
EASY_MACE_OPTION(BUILD_UNIT_TESTS             "Build unit-tests application"       OFF)

# END OPTION

set(THIRD_PARTY_DEPENDENCIES "")

add_subdirectory(external/protobuf-3.4.0)

list(APPEND THIRD_PARTY_DEPENDENCIES "protobuf_lite")

if(BUILD_UNIT_TESTS)
  add_subdirectory(external/googletest)
  include_directories(${gtest_SOURCE_DIR}/include ${gtest_SOURCE_DIR})
  include_directories(${gmock_SOURCE_DIR}/include ${gmock_SOURCE_DIR})
endif()

project(easy_mace CXX C)

# ----------------------------------------------------------------------------
# Break in case of popular CMake configuration mistakes
# ----------------------------------------------------------------------------
if(NOT CMAKE_SIZEOF_VOID_P GREATER 0)
  message(FATAL_ERROR "CMake fails to deterimine the bitness of target platform.
  Please check your CMake and compiler installation. If you are crosscompiling then ensure that your CMake toolchain file correctly sets the compiler details.")
endif()

# static lib or dynamic lib
if(BUILD_SHARED_LIBRARIES)
  set(EASY_MACE_LIBTYPE SHARED)
else()
  set(EASY_MACE_LIBTYPE STATIC)
endif()

# enable neon
if(USE_NEON AND BUILD_IOS_FRAMEWORK)
  add_definitions(-DMACE_ENABLE_NEON)
endif()

# enable opencl
if(USE_OPENCL AND NOT BUILD_IOS_FRAMEWORK)
  add_definitions(-DMACE_ENABLE_OPENCL)
  if(NOT APPLE)
    find_package(OpenCL REQUIRED)
    list(APPEND THIRD_PARTY_DEPENDENCIES ${OpenCL_LIBRARY})
  endif()
endif()

if(DEBUG_OPENCL AND USE_OPENCL)
  # generate mace_dir.h
  set(MACE_DIR "${PROJECT_SOURCE_DIR}")

  # configure a header file to pass mace dir to the source code
  configure_file (
  "${PROJECT_SOURCE_DIR}/mace/codegen/mace_dir.h.in"
  "${PROJECT_SOURCE_DIR}/mace/codegen/mace_dir.h"
  )

  add_definitions(-DMACE_DEBUG_OPENCL)
endif()

if(WIN32)
  add_definitions(-D_CRT_SECURE_NO_WARNINGS)
  add_definitions(-D_CRT_NONSTDC_NO_DEPRECATE)
elseif(APPLE)
  add_definitions(-fembed-bitcode)
  set(CMAKE_CXX_FLAGS "-std=c++11 ${CMAKE_CXX_FLAGS}")
else()
  set(CMAKE_CXX_FLAGS "-std=c++11 -fPIC ${CMAKE_CXX_FLAGS}")
endif()

if(BUILD_IOS_FRAMEWORK)
  set(REMOVE_HEADERS_FROM_FRAMEWORK ON)
  set(CMAKE_OSX_SYSROOT iphoneos)
  set(CMAKE_OSX_ARCHITECTURES "armv7 arm64" CACHE string "Build architecture for iOS")
  set(CMAKE_XCODE_EFFECTIVE_PLATFORMS "-iphoneos;-iphonesimulator")
  set(CMAKE_MACOSX_RPATH OFF)
else()
  set(REMOVE_HEADERS_FROM_FRAMEWORK OFF)
endif()

include_directories("./")
include_directories("external/protobuf-3.4.0/src")
include_directories("external/opencl")
include_directories("external/opencl/opencl12")
include_directories("external/half")

# find sources
set(EASY_MACE_ALL_HEADERS "")
set(EASY_MACE_ALL_SRCS "")
easy_mace_subdirlist(easy_mace_subdirs "mace")
foreach(subdir ${easy_mace_subdirs})
  if(EXISTS "${subdir}/CMakeLists.txt")
    include("${subdir}/CMakeLists.txt")
  endif()
endforeach()

# group files
easy_mace_make_group("${EASY_MACE_ALL_HEADERS}")
easy_mace_make_group("${EASY_MACE_ALL_SRCS}")

# build library
set(libname "mace")
set(EASY_MACE_ALL_LIBS ${libname})
easy_mace_buildlibrary(${libname} ${EASY_MACE_LIBTYPE} SOURCES ${EASY_MACE_ALL_HEADERS} ${EASY_MACE_ALL_SRCS} DEPENDENCIES ${THIRD_PARTY_DEPENDENCIES})
if(USE_OPENCL AND APPLE AND NOT BUILD_IOS_FRAMEWORK)
  easy_mace_add_framework(OpenCL ${libname})
endif()
if(BUILD_IOS_FRAMEWORK)
  file(GLOB EASY_PUBLIC_HEADERS "mace/public/*.h")
  set_source_files_properties(${EASY_PUBLIC_HEADERS} PROPERTIES MACOSX_PACKAGE_LOCATION "Headers/public/")
  easy_mace_set_framework(${libname})
endif()

list(APPEND THIRD_PARTY_DEPENDENCIES "mace")

if(BUILD_TESTS AND NOT BUILD_IOS_FRAMEWORK)
  easy_mace_subdirlist(test_subdirs "tests")
  foreach(subdir ${test_subdirs})
    if(EXISTS "${subdir}/CMakeLists.txt")
	  add_subdirectory(${subdir})
    endif()
  endforeach()
endif()

include_directories("unit_tests")
if(BUILD_UNIT_TESTS)
  easy_mace_add_unit_tests("unit_tests" "${THIRD_PARTY_DEPENDENCIES}")
endif()