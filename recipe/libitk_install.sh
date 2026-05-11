BUILD_DIR=${SRC_DIR}/build
components="Runtime RuntimeLibraries Libraries Unspecified libraries"
for component in ${components}; do
    cmake -DCOMPONENT=${component} -P ${BUILD_DIR}/cmake_install.cmake
done

# ITK's wrapping install rules don't partition cleanly by COMPONENT: pieces of
# the Python payload land in Unspecified / libraries even with
# WRAP_ITK_INSTALL_COMPONENT_IDENTIFIER set. Drop them so libitk-wrapping
# can claim them.
rm -rf "${PREFIX}"/lib/python*/site-packages/itk
rm -f  "${PREFIX}"/lib/python*/site-packages/itkConfig.py
rm -f  "${PREFIX}"/lib/python*/site-packages/__pycache__/itkConfig*.pyc
