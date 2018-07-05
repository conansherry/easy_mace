LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := protobuf-lite

LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/src

LOCAL_C_INCLUDES := $(LOCAL_PATH)/src

LOCAL_SRC_FILES :=  src/google/protobuf/arena.cc \
                    src/google/protobuf/arenastring.cc \
                    src/google/protobuf/extension_set.cc \
                    src/google/protobuf/generated_message_table_driven_lite.cc \
                    src/google/protobuf/generated_message_util.cc \
                    src/google/protobuf/io/coded_stream.cc \
                    src/google/protobuf/io/zero_copy_stream.cc \
                    src/google/protobuf/io/zero_copy_stream_impl_lite.cc \
                    src/google/protobuf/message_lite.cc \
                    src/google/protobuf/repeated_field.cc \
                    src/google/protobuf/stubs/atomicops_internals_x86_gcc.cc \
                    src/google/protobuf/stubs/atomicops_internals_x86_msvc.cc \
                    src/google/protobuf/stubs/bytestream.cc \
                    src/google/protobuf/stubs/common.cc \
                    src/google/protobuf/stubs/int128.cc \
                    src/google/protobuf/stubs/io_win32.cc \
                    src/google/protobuf/stubs/once.cc \
                    src/google/protobuf/stubs/status.cc \
                    src/google/protobuf/stubs/statusor.cc \
                    src/google/protobuf/stubs/stringpiece.cc \
                    src/google/protobuf/stubs/stringprintf.cc \
                    src/google/protobuf/stubs/structurally_valid.cc \
                    src/google/protobuf/stubs/strutil.cc \
                    src/google/protobuf/stubs/time.cc \
                    src/google/protobuf/wire_format_lite.cc

LOCAL_CPPFLAGS += -O3 -std=c++11 -Wall -Wno-unused -Wno-sign-compare -DHAVE_PTHREAD

#LOCAL_LDLIBS += -pthread -llog
#include $(BUILD_SHARED_LIBRARY)

include $(BUILD_STATIC_LIBRARY)