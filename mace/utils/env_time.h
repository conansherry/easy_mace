// Copyright 2018 Xiaomi, Inc.  All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#ifndef MACE_UTILS_ENV_TIME_H_
#define MACE_UTILS_ENV_TIME_H_

#include <stdint.h>
#ifdef __hexagon__
#include <HAP_perf.h>
#elif defined(_WIN32)
#include <ctime>
#define WIN32_LEAN_AND_MEAN 
#include <windows.h>
#undef small
#undef min
#undef max
#undef abs
#elif defined __MACH__ && defined __APPLE__
#include <sys/time.h>
#include <mach/mach_time.h>
#else
#include <sys/time.h>
#endif

namespace mace {

inline int64_t NowMicros() {
#ifdef __hexagon__
  return HAP_perf_get_time_us();
#elif defined(_WIN32)
  LARGE_INTEGER counter;
  QueryPerformanceCounter(&counter);
  return (int64_t)counter.QuadPart;
#elif defined __linux || defined __linux__
    struct timespec tp;
    clock_gettime(CLOCK_MONOTONIC, &tp);
    return (int64_t)tp.tv_sec*1000000000 + tp.tv_nsec;
#elif defined __MACH__ && defined __APPLE__
    return (int64_t)mach_absolute_time();
#else
    struct timeval tv;
    struct timezone tz;
    gettimeofday( &tv, &tz );
    return (int64_t)tv.tv_sec*1000000 + tv.tv_usec;
#endif
}

inline double TickFerquency() {
#if defined _WIN32
    LARGE_INTEGER freq;
    QueryPerformanceFrequency(&freq);
    return (double)freq.QuadPart;
#elif defined __linux || defined __linux__
    return 1e9;
#elif defined __MACH__ && defined __APPLE__
    static double freq = 0;
    if (freq == 0)
    {
        mach_timebase_info_data_t sTimebaseInfo;
        mach_timebase_info(&sTimebaseInfo);
        freq = sTimebaseInfo.denom * 1e9 / sTimebaseInfo.numer;
    }
    return freq;
#else
    return 1e6;
#endif
}

}  // namespace mace

#endif  // MACE_UTILS_ENV_TIME_H_
