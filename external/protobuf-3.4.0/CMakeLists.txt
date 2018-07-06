# ----------------------------------------------------------------------------
#  Root CMake file for easy mace
#
#  author: conansherry
# ----------------------------------------------------------------------------

project(protobuf_lite CXX C)

include_directories("src")
file(GLOB_RECURSE PROTOBUF_SRC "src/*.cc")
if(WIN32)
  add_library(protobuf_lite STATIC ${PROTOBUF_SRC})
  list(APPEND THIRD_PARTY_DEPENDENCIES "protobuf_lite")
  if(BUILD_IOS_FRAMEWORK)
    set_target_properties(protobuf_lite PROPERTIES XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET "8.0")
  endif()
endif()