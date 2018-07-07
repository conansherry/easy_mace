#pragma once

#include <cstdio>
#include <cstdlib>

namespace mace
{

    int mace_memalign(void **ptr, size_t align, size_t size);

    void mace_memfree(void *ptr);

}
