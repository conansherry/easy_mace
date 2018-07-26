set(test_name "test_segmentation")
project(${test_name} CXX C)

# header files
file(GLOB TEST_HEADERS "*.hpp" "*.h")
set(TEST_HEADERS ${TEST_HEADERS})

# source files
file(GLOB TEST_SOURCES "*.cpp" "*.cc")
set(TEST_SOURCES ${TEST_SOURCES})

source_group("include\\" FILES ${TEST_HEADERS})
source_group("src\\" FILES ${TEST_SOURCES})

set(CUSTOM_DEPENDENCIES ${THIRD_PARTY_DEPENDENCIES})

find_package(OpenCV 3.2.0 REQUIRED)
include_directories(${OpenCV_INCLUDE_DIRS})
list(APPEND CUSTOM_DEPENDENCIES ${OpenCV_LIBS})

easy_mace_build_test(${test_name} "${TEST_HEADERS}" "${TEST_SOURCES}" "${CUSTOM_DEPENDENCIES}")