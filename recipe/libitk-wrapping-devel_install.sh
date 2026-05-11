#!/bin/bash
set -euo pipefail

BUILD_DIR=${SRC_DIR}/build
ITK_VERSION_MM=$(echo "${PKG_VERSION}" | awk -F. '{print $1"."$2}')
ITK_CMAKE_DEST="${PREFIX}/lib/cmake/ITK-${ITK_VERSION_MM}"
WRAP_CMAKE_DEST="${PREFIX}/lib/cmake/Wrapping"
TYPEDEFS_DEST="${ITK_CMAKE_DEST}/Wrapping/Typedefs"
INCLUDE_DEST="${PREFIX}/include/ITK-${ITK_VERSION_MM}"

mkdir -p "${ITK_CMAKE_DEST}"
mkdir -p "${WRAP_CMAKE_DEST}"

# Wrapping CMake helpers that ITKModuleExternal.cmake includes by name.
cp "${SRC_DIR}/CMake/WrappingConfigCommon.cmake" "${ITK_CMAKE_DEST}/WrappingConfigCommon.cmake"
cp "${SRC_DIR}/CMake/ITKSetPython3Vars.cmake"     "${ITK_CMAKE_DEST}/ITKSetPython3Vars.cmake"

# Full Wrapping/ source tree. ITKModuleExternal.cmake sets
# WRAP_ITK_CMAKE_DIR = ${ITK_CMAKE_DIR}/../Wrapping, which resolves to this
# location given ITK_CMAKE_DIR = ${ITK_CMAKE_DEST}.
cp -R "${SRC_DIR}/Wrapping/." "${WRAP_CMAKE_DEST}/"

# Per-module wrapping/ subdirs (Modules/<Group>/<Module>/wrapping/) so that
# external builds re-using ITK module sources can resolve .wrap dependencies.
cd "${SRC_DIR}"
while IFS= read -r wrap_src; do
    rel="${wrap_src#./}"           # e.g. Modules/Core/Common/wrapping
    dest="${INCLUDE_DEST}/${rel}"
    mkdir -p "${dest}"
    cp -R "${wrap_src}/." "${dest}/"
done < <(find Modules -type d -name wrapping)

# Every module's itk-module.cmake. Downstream wheel-build tooling derives
# ITK_MODULE_<M>_GROUP from the directory layout, so the file location matters.
# Ship all of them (including ThirdParty) since the dependency walk reads GROUP
# for non-wrapped deps too.
while IFS= read -r module_cmake; do
    rel="${module_cmake#./}"       # e.g. Modules/Core/Common/itk-module.cmake
    dest_dir="${INCLUDE_DEST}/$(dirname "${rel}")"
    mkdir -p "${dest_dir}"
    cp "${module_cmake}" "${dest_dir}/itk-module.cmake"
done < <(find Modules -name itk-module.cmake)

# Build-tree wrapping artifacts (.i, .idx, .mdx, pyBase.i, python/*_ext.i) that
# upstream ITK doesn't install. Required at ${ITK_CMAKE_DIR}/Wrapping/Typedefs/
# for consumer SWIG runs to resolve %import "pyBase.i" and .mdx dependencies.
mkdir -p "${TYPEDEFS_DEST}"
cp -R "${BUILD_DIR}/Wrapping/Typedefs/." "${TYPEDEFS_DEST}/"

# Append Eigen3 + module-include hook to the installed WrappingConfigCommon.cmake.
WRAP_CFG="${ITK_CMAKE_DEST}/WrappingConfigCommon.cmake"
if [[ -f "${WRAP_CFG}" ]]; then
    cat >> "${WRAP_CFG}" <<'EOF'

# Added by libitk-feedstock: castxml's include set comes from
# get_directory_property(... INCLUDE_DIRECTORIES), which doesn't pick up
# target-only includes (Eigen3::Eigen) or the consumer module's own include/
# dirs. Push them onto the directory property here.
if(TARGET Eigen3::Eigen)
  get_target_property(_libitk_wrap_eigen_incs
    Eigen3::Eigen INTERFACE_INCLUDE_DIRECTORIES)
  if(_libitk_wrap_eigen_incs)
    include_directories(${_libitk_wrap_eigen_incs})
  endif()
  unset(_libitk_wrap_eigen_incs)
endif()
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/include")
  include_directories("${CMAKE_CURRENT_SOURCE_DIR}/include")
endif()
# Binary include/ for generate_export_header outputs; the dir is created
# during the build before castxml runs.
include_directories("${CMAKE_CURRENT_BINARY_DIR}/include")
EOF
fi
