#pragma once

#include <cstdio>
#include <cstdlib>
#include <sys/stat.h>

#if defined(_WIN32)
// Copied from linux libc sys/stat.h:
#define S_ISREG(m) (((m) & S_IFMT) == S_IFREG)
#define S_ISDIR(m) (((m) & S_IFMT) == S_IFDIR)
#endif

#ifdef _WIN32
//define something for Windows (32-bit and 64-bit, this part is common)
#define EASY_MACE_WIN
#ifdef _WIN64
//define something for Windows (64-bit only)
#define EASY_MACE_WIN64
#endif
#elif __APPLE__
#include "TargetConditionals.h"
#if TARGET_IPHONE_SIMULATOR
// iOS Simulator
#define EASY_MACE_IOS_SIMULATOR
#elif TARGET_OS_IPHONE
// iOS device
#define EASY_MACE_IOS
#elif TARGET_OS_MAC
// Other kinds of Mac OS
#define EASY_MACE_MACOS
#else
#error "Unknown Apple platform"
#endif
#elif __ANDROID__
// Android
#define EASY_MACE_ANDROID
#elif __linux__
// linux
#define EASY_MACE_LINUX
#elif __unix__ // all unices not caught above
// Unix
#define EASY_MACE_UNIX
#elif defined(_POSIX_VERSION)
// POSIX
#define EASY_MACE_POSIX
#else
#error "Unknown compiler"
#endif

namespace mace
{

    int mace_memalign(void **ptr, size_t align, size_t size);

    void mace_memfree(void *ptr);

}
