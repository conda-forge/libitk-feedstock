#!/bin/bash

# When building 32-bits on 64-bit system this flags is not automatically set by conda-build
if [ $ARCH == 32 -a "${OSX_ARCH:-notosx}" == "notosx" ]; then
    export CFLAGS="${CFLAGS} -m32"
    export CXXFLAGS="${CXXFLAGS} -m32"
fi

use_tbb=ON
if [ "$(uname)" == "Darwin" ]; then
   use_tbb=OFF
fi

# Skip Python wrapping on linux-ppc64le: castxml's bundled Clang can't parse
# PowerPC's __float128/__ieee128 (used by libstdc++ <limits>) or Eigen's
# AltiVec PacketMath. Neither PyPI itk nor conda-forge itk ship for ppc64le.
itk_wrap_python=ON
if [ "${target_platform}" == "linux-ppc64le" ]; then
    itk_wrap_python=OFF
fi


BUILD_DIR=${SRC_DIR}/build
mkdir ${BUILD_DIR}
cd ${BUILD_DIR}

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == 1 ]]; then
    try_run_results="${RECIPE_DIR}/TryRunResults-${target_platform}.cmake"
    if [[ -f "$try_run_results" ]]; then
        CMAKE_ARGS="${CMAKE_ARGS} -C ${try_run_results}"
    fi
    # Target-arch Python hints. find_package(Python3 Development.Module)
    # otherwise introspects ${PYTHON} (BUILD x86_64 headers) which
    # CMAKE_FIND_ROOT_PATH=${PREFIX} then filters out.
    CMAKE_ARGS="${CMAKE_ARGS} -DPython3_INCLUDE_DIR:PATH=${PREFIX}/include/python${PY_VER}"
    CMAKE_ARGS="${CMAKE_ARGS} -DPython3_LIBRARY:FILEPATH=${PREFIX}/lib/libpython${PY_VER}.so"
    # Castxml (Clang-based) needs an explicit target triple under cross-compile;
    # ITK's wrapping reads CMAKE_CXX_COMPILER_TARGET in itk_auto_load_submodules.cmake.
    CMAKE_ARGS="${CMAKE_ARGS} -DCMAKE_CXX_COMPILER_TARGET=${HOST}"
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
    -D ITK_USE_SYSTEM_OPENJPEG:BOOL=ON \
    -D ITK_USE_FFTWD:BOOL=ON \
    -D ITK_USE_FFTWF:BOOL=ON \
    -D ITK_USE_KWSTYLE:BOOL=OFF \
    -D ITK_BUILD_DEFAULT_MODULES:BOOL=ON \
    -D NIFTI_SYSTEM_MATH_LIB= \
    -D GDCM_USE_COREFOUNDATION_LIBRARY:BOOL=OFF \
    -D Module_ITKReview:BOOL=ON \
    -D Module_SimpleITKFilters=ON \
    -D Module_ITKTBB:BOOL=${use_tbb} \
    -D Module_MGHIO:BOOL=ON \
    -D Module_ITKIOTransformMINC:BOOL=ON \
    -D Module_GenericLabelInterpolator:BOOL=ON \
    -D Module_AdaptiveDenoising:BOOL=ON \
    -D "ITK_DEFAULT_THREADER:STRING=Pool" \
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
    -D ITK_WRAP_PYTHON:BOOL=${itk_wrap_python} \
    -D ITK_USE_SYSTEM_CASTXML:BOOL=ON \
    -D WRAP_ITK_INSTALL_COMPONENT_IDENTIFIER:STRING=PythonWrapping \
    -D Python3_EXECUTABLE:FILEPATH="${PYTHON}" \
    -D ITK_WRAP_unsigned_short:BOOL=ON \
    -D ITK_WRAP_double:BOOL=ON \
    -D ITK_WRAP_complex_double:BOOL=ON \
    -D ITK_WRAP_IMAGE_DIMS:STRING="2;3;4" \
    -D PY_SITE_PACKAGES_PATH:PATH="lib/python${PY_VER}/site-packages" \
    "${SRC_DIR}"

cmake --build . --config Release -- -j${CPU_COUNT}
