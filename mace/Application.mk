APP_STL := gnustl_static

APP_CPPFLAGS += -fexceptions -frtti
APP_LDFLAGS += -Wl,--no-warn-mismatch

APP_ABI := armeabi-v7a
APP_PLATFORM := android-21
APP_BUILD_SCRIPT := Android.mk