set BUILD_DIR=%SRC_DIR%\bld
cmake -DCOMPONENT=Runtime -P %BUILD_DIR%\cmake_install.cmake
cmake -DCOMPONENT=RuntimeLibraries -P %BUILD_DIR%\cmake_install.cmake
cmake -DCOMPONENT=Libraries -P %BUILD_DIR%\cmake_install.cmake
cmake -DCOMPONENT=Unspecified -P %BUILD_DIR%\cmake_install.cmake
cmake -DCOMPONENT=libraries -P %BUILD_DIR%\cmake_install.cmake
