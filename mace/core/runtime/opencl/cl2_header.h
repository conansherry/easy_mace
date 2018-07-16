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

#ifndef MACE_CORE_RUNTIME_OPENCL_CL2_HEADER_H_
#define MACE_CORE_RUNTIME_OPENCL_CL2_HEADER_H_

// Do not include cl2.hpp directly, include this header instead.

#define CL_HPP_MINIMUM_OPENCL_VERSION 110
#define CL_HPP_TARGET_OPENCL_VERSION 120

#include "include/CL/cl2.hpp"

#ifdef __APPLE__
/*********************************
 * cl_arm_printf extension
 *********************************/
#define CL_PRINTF_CALLBACK_ARM                      0x40B0
#define CL_PRINTF_BUFFERSIZE_ARM                    0x40B1
#endif

#endif  // MACE_CORE_RUNTIME_OPENCL_CL2_HEADER_H_
