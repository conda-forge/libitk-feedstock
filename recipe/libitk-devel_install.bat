set BUILD_DIR=%SRC_DIR%\bld
cmake -DCOMPONENT=Development -P %BUILD_DIR%\cmake_install.cmake
cmake -DCOMPONENT=DebugDevel -P %BUILD_DIR%\cmake_install.cmake
cmake -DCOMPONENT=cpplibraries  -P %BUILD_DIR%\cmake_install.cmake


