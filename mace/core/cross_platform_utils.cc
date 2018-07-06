#include <errno.h>

#include "mace/core/cross_platform_utils.h"

namespace mace {

#ifdef _WIN32
    static int check_align(size_t align)
    {
        for (size_t i = sizeof(void *); i != 0; i *= 2)
            if (align == i)
                return 0;
        return EINVAL;
    }

    int posix_memalign(void **ptr, size_t align, size_t size)
    {
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
    }
#endif

}