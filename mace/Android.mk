LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := easy_mace

LOCAL_C_INCLUDES := $(LOCAL_PATH)/../external/half \
                    $(LOCAL_PATH)/../external/opencl \
                    $(LOCAL_PATH)/../external/opencl/opencl20 \
                    $(LOCAL_PATH)/..
                    
# core
SOURCE_LIST := $(wildcard $(LOCAL_PATH)/core/*.cc)
LOCAL_SRC_FILES += $(SOURCE_LIST:$(LOCAL_PATH)/%=%)

# core/runtime/cpu
SOURCE_LIST := $(wildcard $(LOCAL_PATH)/core/runtime/cpu/*.cc)
LOCAL_SRC_FILES += $(SOURCE_LIST:$(LOCAL_PATH)/%=%)

# core/runtime/opencl
ifeq ($(USE_OPENCL), on)
    SOURCE_LIST := $(wildcard $(LOCAL_PATH)/core/runtime/opencl/*.cc)
    LOCAL_SRC_FILES += $(SOURCE_LIST:$(LOCAL_PATH)/%=%)
endif

# kernels
SOURCE_LIST := $(wildcard $(LOCAL_PATH)/kernels/*.cc)
LOCAL_SRC_FILES += $(SOURCE_LIST:$(LOCAL_PATH)/%=%)

# kernels/arm
SOURCE_LIST := $(wildcard $(LOCAL_PATH)/kernels/arm/*.cc)
LOCAL_SRC_FILES += $(SOURCE_LIST:$(LOCAL_PATH)/%=%)

# kernels/opencl
ifeq ($(USE_OPENCL), on)
    SOURCE_LIST := $(wildcard $(LOCAL_PATH)/kernels/opencl/*.cc)
    LOCAL_SRC_FILES += $(SOURCE_LIST:$(LOCAL_PATH)/%=%)
endif

# ops
SOURCE_LIST := $(wildcard $(LOCAL_PATH)/ops/*.cc)

ifeq ($(USE_OPENCL), off)
    SOURCE_LIST := $(filter-out $(LOCAL_PATH)/ops/buffer_to_image.cc, $(SOURCE_LIST))
    SOURCE_LIST := $(filter-out $(LOCAL_PATH)/ops/image_to_buffer.cc, $(SOURCE_LIST))
endif

LOCAL_SRC_FILES += $(SOURCE_LIST:$(LOCAL_PATH)/%=%)

# proto
SOURCE_LIST := $(wildcard $(LOCAL_PATH)/proto/*.cc)
LOCAL_SRC_FILES += $(SOURCE_LIST:$(LOCAL_PATH)/%=%)

# utils
SOURCE_LIST := $(wildcard $(LOCAL_PATH)/utils/*.cc)
SOURCE_LIST := $(filter-out $(LOCAL_PATH)/utils/tuner_development.cc, $(SOURCE_LIST))
SOURCE_LIST := $(filter-out $(LOCAL_PATH)/utils/tuner_production.cc, $(SOURCE_LIST))
LOCAL_SRC_FILES += $(SOURCE_LIST:$(LOCAL_PATH)/%=%)

# codegen/version
SOURCE_LIST := $(wildcard $(LOCAL_PATH)/codegen/version/*.cc)
LOCAL_SRC_FILES += $(SOURCE_LIST:$(LOCAL_PATH)/%=%)

# codegen/tuning
SOURCE_LIST := $(wildcard $(LOCAL_PATH)/codegen/tuning/*.cc)
LOCAL_SRC_FILES += $(SOURCE_LIST:$(LOCAL_PATH)/%=%)

# codegen/opencl
ifeq ($(USE_OPENCL), on)
    SOURCE_LIST := $(wildcard $(LOCAL_PATH)/codegen/opencl/*.cc)
    LOCAL_SRC_FILES += $(SOURCE_LIST:$(LOCAL_PATH)/%=%)
endif

LOCAL_CFLAGS += -Os -Wall -fPIC
LOCAL_CPPFLAGS += -Os -std=c++11 -Wall -fPIC -D__STDC_LIMIT_MACROS

ifeq ($(USE_OPENMP), on)
	LOCAL_CFLAGS += -DMACE_ENABLE_OPENMP -fopenmp
	LOCAL_CPPFLAGS += -DMACE_ENABLE_OPENMP -fopenmp
endif

ifeq ($(USE_NEON), on)
    LOCAL_ARM_NEON := true
	LOCAL_CFLAGS += -DMACE_ENABLE_NEON
	LOCAL_CPPFLAGS += -DMACE_ENABLE_NEON
endif

ifeq ($(USE_OPENCL), on)
	LOCAL_CFLAGS += -DMACE_ENABLE_OPENCL
	LOCAL_CPPFLAGS += -DMACE_ENABLE_OPENCL
endif

#LOCAL_LDLIBS += -llog
#LOCAL_STATIC_LIBRARIES += protobuf-lite
#include $(BUILD_SHARED_LIBRARY)

LOCAL_STATIC_LIBRARIES += protobuf-lite
include $(BUILD_STATIC_LIBRARY)

include $(LOCAL_PATH)/../external/protobuf-3.4.0/Android.mk