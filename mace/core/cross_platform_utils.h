#pragma once

#include <cstdio>
#include <cstdlib>

namespace mace
{

#ifdef _WIN32
    int posix_memalign(void **ptr, size_t align, size_t size);
#endif

}
