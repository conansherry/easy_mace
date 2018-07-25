# easy mace (easy Mobile AI Compute Engine)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
* Thanks to [XiaoMI/mace](https://github.com/XiaoMi/mace)
* easy mace update to [8fae54d17bbebf0392c1966d1116cf214c1c965c](https://github.com/XiaoMi/mace/tree/8fae54d17bbebf0392c1966d1116cf214c1c965c) (support caffe deconv)

## How to build
* Android
  * use ndk-build
  * three switch in easy_mace/mace/Application.mk
    * USE_OPENMP
    * USE_NEON
    * USE_OPENCL
  * builed pass in android-9
* Windows
  * use cmake
  * builed pass in windows(vs2015)
  * can USE_OPENCL in cmake config
* MacOS
  * use cmake
  * can USE_OPENCL in cmake config(link with OpenCL.framework)
* IOS(not test)
  * use cmake.
  * need to enable BUILD_IOS_FRAMEWORK in cmake config.
  * can USE_NEON in cmake config
  * generate two framework after Product/Archive
  
## Convert caffe model
* use [convert_model](https://github.com/conansherry/convert_model) tool

## To do
* enable shared libraries in windows
* enable openmp in windows/mac/ios
* use cmake in all platforms(win/linux/mac/android)