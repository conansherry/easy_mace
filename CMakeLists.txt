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

EASY_MACE_OPTION(BUILD_SHARED_LIBRARIES       "Build shared library"               OFF)
EASY_MACE_OPTION(BUILD_IOS_FRAMEWORK          "Build ios framework"                OFF)

# END OPTION

set(THIRD_PARTY_DEPENDENCIES "")

add_subdirectory(external/protobuf-3.4.0)

list(APPEND THIRD_PARTY_DEPENDENCIES "protobuf_lite")

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

if(WIN32)
  add_definitions(-D_CRT_SECURE_NO_WARNINGS)
  add_definitions(-D_CRT_NONSTDC_NO_DEPRECATE)
elseif(APPLE)
  add_definitions(-fembed-bitcode)
endif()

include_directories("./")
include_directories("external/protobuf-3.4.0/src")
include_directories("external/opencl")
include_directories("external/opencl/opencl20")
include_directories("external/half")

# find sources
set(EASY_MACE_ALL_HEADERS "")
set(EASY_MACE_ALL_SRCS "")
easy_mace_subdirlist(easy_mace_subdirs "mace")
foreach(subdir ${easy_mace_subdirs})
  if(EXISTS "${subdir}/CMakeLists.txt")
    message(STATUS "${subdir}/CMakeLists.txt")
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
if(USE_ACCELERATE)
  easy_mace_add_framework(Accelerate ${libname})
endif()
if(BUILD_IOS_FRAMEWORK)
  easy_mace_add_framework(opencv2 ${libname})
  easy_mace_set_framework(${libname})
endif()