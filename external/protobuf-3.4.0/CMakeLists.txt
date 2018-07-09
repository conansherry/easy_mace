# ----------------------------------------------------------------------------
#  Root CMake file for easy mace
#
#  author: conansherry
# ----------------------------------------------------------------------------

project(protobuf_lite CXX C)

include_directories("src")
file(GLOB_RECURSE PROTOBUF_SRC "src/*.cc")
add_library(protobuf_lite STATIC ${PROTOBUF_SRC})
list(APPEND THIRD_PARTY_DEPENDENCIES "protobuf_lite")
if(BUILD_IOS_FRAMEWORK)
  set_target_properties(protobuf_lite PROPERTIES XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET "8.0")
endif()
if(NOT WIN32)
  find_package(Threads REQUIRED)
  if(CMAKE_USE_PTHREADS_INIT)
    add_definitions(-DHAVE_PTHREAD)
    target_compile_options(protobuf_lite PUBLIC "-pthread")
  endif()
endif()
