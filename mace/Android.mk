LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := easy_mace

LOCAL_C_INCLUDES := $(LOCAL_PATH)/../external/half \
                    $(LOCAL_PATH)/../external/opencl \
                    $(LOCAL_PATH)/../external/opencl/opencl20 \
                    $(LOCAL_PATH)/../external/half \
                    $(LOCAL_PATH)/..
                    
# core
SOURCE_LIST := $(wildcard $(LOCAL_PATH)/core/*.cc)
LOCAL_SRC_FILES += $(SOURCE_LIST:$(LOCAL_PATH)/%=%)

# kernels
SOURCE_LIST := $(wildcard $(LOCAL_PATH)/kernels/*.cc)
LOCAL_SRC_FILES += $(SOURCE_LIST:$(LOCAL_PATH)/%=%)

# kernels/arm
SOURCE_LIST := $(wildcard $(LOCAL_PATH)/kernels/arm/*.cc)
LOCAL_SRC_FILES += $(SOURCE_LIST:$(LOCAL_PATH)/%=%)

# kernels/opencl
#SOURCE_LIST := $(wildcard $(LOCAL_PATH)/kernels/opencl/*.cc)
#LOCAL_SRC_FILES += $(SOURCE_LIST:$(LOCAL_PATH)/%=%)

# ops
SOURCE_LIST := $(wildcard $(LOCAL_PATH)/ops/*.cc)
SOURCE_LIST := $(filter-out $(LOCAL_PATH)/ops/buffer_to_image.cc, $(SOURCE_LIST))
SOURCE_LIST := $(filter-out $(LOCAL_PATH)/ops/image_to_buffer.cc, $(SOURCE_LIST))
LOCAL_SRC_FILES += $(SOURCE_LIST:$(LOCAL_PATH)/%=%)

# proto
SOURCE_LIST := $(wildcard $(LOCAL_PATH)/proto/*.cc)
LOCAL_SRC_FILES += $(SOURCE_LIST:$(LOCAL_PATH)/%=%)

# utils
SOURCE_LIST := $(wildcard $(LOCAL_PATH)/utils/*.cc)
SOURCE_LIST := $(filter-out $(LOCAL_PATH)/utils/tuner_development.cc, $(SOURCE_LIST))
SOURCE_LIST := $(filter-out $(LOCAL_PATH)/utils/tuner_production.cc, $(SOURCE_LIST))
LOCAL_SRC_FILES += $(SOURCE_LIST:$(LOCAL_PATH)/%=%)

# version
SOURCE_LIST := $(wildcard $(LOCAL_PATH)/version/*.cc)
LOCAL_SRC_FILES += $(SOURCE_LIST:$(LOCAL_PATH)/%=%)

# tuning
#SOURCE_LIST := $(wildcard $(LOCAL_PATH)/tuning/*.cc)
#LOCAL_SRC_FILES += $(SOURCE_LIST:$(LOCAL_PATH)/%=%)

LOCAL_CFLAGS += -Os -fPIC -Wall -Wno-unused -Wno-sign-compare
LOCAL_CPPFLAGS += -Os -std=c++11 -Wall -Wno-unused -Wno-sign-compare

#LOCAL_LDLIBS += -llog
#LOCAL_STATIC_LIBRARIES += protobuf-lite
#include $(BUILD_SHARED_LIBRARY)

LOCAL_STATIC_LIBRARIES += protobuf-lite
include $(BUILD_STATIC_LIBRARY)

include $(LOCAL_PATH)/../external/protobuf-3.4.0/Android.mk