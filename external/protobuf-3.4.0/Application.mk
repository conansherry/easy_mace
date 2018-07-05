APP_STL := gnustl_shared

APP_CPPFLAGS += -fexceptions -frtti
APP_LDFLAGS += -Wl,--no-warn-mismatch

APP_ABI := armeabi-v7a
APP_PLATFORM := android-14
APP_BUILD_SCRIPT := Android.mk