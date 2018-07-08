#pragma once

#include <cstdio>
#include <cstdlib>
#include <sys/stat.h>

#if defined(_WIN32)
// Copied from linux libc sys/stat.h:
#define S_ISREG(m) (((m) & S_IFMT) == S_IFREG)
#define S_ISDIR(m) (((m) & S_IFMT) == S_IFDIR)
#endif

namespace mace
{

    int mace_memalign(void **ptr, size_t align, size_t size);

    void mace_memfree(void *ptr);

}
