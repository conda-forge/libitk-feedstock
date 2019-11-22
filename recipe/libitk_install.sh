BUILD_DIR=${SRC_DIR}/build
components="Runtime RuntimeLibraries Libraries Unspecified libraries"
for component in ${components}; do 
    cmake -DCOMPONENT=${component} -P ${BUILD_DIR}/cmake_install.cmake
done
