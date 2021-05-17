#!/bin/bash

# When building 32-bits on 64-bit system this flags is not automatically set by conda-build
if [ $ARCH == 32 -a "${OSX_ARCH:-notosx}" == "notosx" ]; then
    export CFLAGS="${CFLAGS} -m32"
    export CXXFLAGS="${CXXFLAGS} -m32"
fi


BUILD_DIR=${SRC_DIR}/build
mkdir ${BUILD_DIR}
cd ${BUILD_DIR}

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == 1 ]]; then
    try_run_results="${RECIPE_DIR}/TryRunResults-${target_platform}.cmake"
    if [[ -f "$try_run_results" ]]; then
        CMAKE_ARGS="${CMAKE_ARGS} -C ${try_run_results}"
    fi
fi


cmake \
    -G "Ninja" \
    ${CMAKE_ARGS} \
    -D BUILD_SHARED_LIBS:BOOL=ON \
    -D BUILD_TESTING:BOOL=OFF \
    -D BUILD_EXAMPLES:BOOL=OFF \
    -D ITK_USE_SYSTEM_EXPAT:BOOL=ON \
    -D ITK_USE_SYSTEM_HDF5:BOOL=ON \
    -D ITK_USE_SYSTEM_JPEG:BOOL=ON \
    -D ITK_USE_SYSTEM_PNG:BOOL=ON \
    -D ITK_USE_SYSTEM_TIFF:BOOL=ON \
    -D ITK_USE_SYSTEM_ZLIB:BOOL=ON \
    -D ITK_USE_SYSTEM_FFTW:BOOL=ON \
    -D ITK_USE_SYSTEM_EIGEN:BOOL=ON \
    -D ITK_USE_FFTWD:BOOL=ON \
    -D ITK_USE_FFTWF:BOOL=ON \
    -D ITK_USE_KWSTYLE:BOOL=OFF \
    -D ITK_BUILD_DEFAULT_MODULES:BOOL=ON \
    -D GDCM_USE_COREFOUNDATION_LIBRARY:BOOL=OFF \
    -D Module_ITKReview:BOOL=ON \
    -D Module_SimpleITKFilters=ON \
    -D "CMAKE_BUILD_TYPE:STRING=RELEASE" \
    -D "CMAKE_FIND_ROOT_PATH:PATH=${PREFIX}" \
    -D "CMAKE_FIND_ROOT_PATH_MODE_INCLUDE:STRING=ONLY" \
    -D "CMAKE_FIND_ROOT_PATH_MODE_LIBRARY:STRING=ONLY" \
    -D "CMAKE_FIND_ROOT_PATH_MODE_PROGRAM:STRING=NEVER" \
    -D "CMAKE_FIND_ROOT_PATH_MODE_PACKAGE:STRING=ONLY" \
    -D "CMAKE_FIND_FRAMEWORK:STRING=NEVER" \
    -D "CMAKE_FIND_APPBUNDLE:STRING=NEVER" \
    -D "CMAKE_INSTALL_PREFIX=${PREFIX}" \
    -D "CMAKE_PROGRAM_PATH=${BUILD_PREFIX}" \
    "${SRC_DIR}"

cmake --build . --config Release
