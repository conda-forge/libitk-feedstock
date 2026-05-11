BUILD_DIR=${SRC_DIR}/build
cmake -DCOMPONENT=Development -P ${BUILD_DIR}/cmake_install.cmake
cmake -DCOMPONENT=Headers -P ${BUILD_DIR}/cmake_install.cmake

# CMake module-build helpers not installed by upstream ITK's Development /
# Headers components. Required for external (remote-module) projects to
# find_package(ITK) and include(ITKModuleExternal).
ITK_VERSION_MM=$(echo "${PKG_VERSION}" | awk -F. '{print $1"."$2}')
ITK_CMAKE_DEST="${PREFIX}/lib/cmake/ITK-${ITK_VERSION_MM}"
KWSTYLE_DEST="${PREFIX}/lib/cmake/Utilities/KWStyle"
mkdir -p "${ITK_CMAKE_DEST}"
mkdir -p "${KWSTYLE_DEST}"
for f in \
    ITKModuleExternal.cmake \
    ITKModuleMacros.cmake \
    ITKModuleDoxygen.cmake \
    ITKModuleHeaderTest.cmake \
    ITKModuleKWStyleTest.cmake \
    ITKModuleCPPCheckTest.cmake \
    ITKModuleTest.cmake \
    ITKExternalData.cmake \
    ITKDownloadSetup.cmake \
    ITKInitializeBuildType.cmake \
    ExternalData.cmake \
    ExternalData_config.cmake.in \
    ITKModuleInfo.cmake.in \
    ITKKWStyleConfig.cmake.in \
    CppcheckTargets.cmake \
    TopologicalSort.cmake
do
    cp "${SRC_DIR}/CMake/${f}" "${ITK_CMAKE_DEST}/${f}"
done

# ITKModuleKWStyleTest.cmake unconditionally includes
# ${ITK_CMAKE_DIR}/../Utilities/KWStyle/BuildKWStyle.cmake, so it has to be on
# disk even when KWStyle itself isn't available.
cp "${SRC_DIR}/Utilities/KWStyle/BuildKWStyle.cmake" "${KWSTYLE_DEST}/BuildKWStyle.cmake"
cp "${SRC_DIR}/Utilities/KWStyle/KWStyle.cmake"      "${KWSTYLE_DEST}/KWStyle.cmake"

# itk_module_test invokes BuildHeaderTest.py via the same ${ITK_CMAKE_DIR}/../
# path convention.
MAINT_DEST="${PREFIX}/lib/cmake/Utilities/Maintenance"
mkdir -p "${MAINT_DEST}"
cp "${SRC_DIR}/Utilities/Maintenance/BuildHeaderTest.py" "${MAINT_DEST}/BuildHeaderTest.py"
