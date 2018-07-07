# easy mace (easy Mobile AI Compute Engine)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
* Thanks to [XiaoMI/mace](https://github.com/XiaoMi/mace)

## Getting started

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

## To do
* enable shared libraries in windows
* enable openmp/opencl in windows
* builed pass in xcode(mac & ios)
* use cmake in all platforms(win/linux/mac/android)