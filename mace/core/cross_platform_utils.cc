#include <errno.h>

#include "mace/core/cross_platform_utils.h"

namespace mace {

static int check_align(size_t align)
{
    for (size_t i = sizeof(void *); i != 0; i *= 2)
        if (align == i)
            return 0;
    return EINVAL;
}

int mace_memalign(void **ptr, size_t align, size_t size)
{
#ifdef _WIN32
    if (check_align(align))
        return EINVAL;

    int saved_errno = errno;
    void *p = _aligned_malloc(size, align);
    if (p == NULL)
    {
        errno = saved_errno;
        return ENOMEM;
    }

    *ptr = p;
    return 0;
#elif defined(__ANDROID__) || defined(__hexagon__)
    void *p = memalign(align, size);
    if (p == NULL)
    {
        return -1;
    }

    *ptr = p;
    return 0;
#else
    return posix_memalign(ptr, align, size);
#endif
}

void mace_memfree(void * ptr)
{
#ifdef _WIN32
    _aligned_free(ptr);
#else
    free(ptr);
#endif
}

}