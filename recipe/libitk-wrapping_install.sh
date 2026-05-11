#!/bin/bash
set -euo pipefail
BUILD_DIR=${SRC_DIR}/build

# ITK's wrapping install rules don't cleanly partition by COMPONENT, so a
# narrow `cmake -DCOMPONENT=PythonWrappingRuntimeLibraries` install only
# installs itkConfig.py. Include all components that may carry wrapping payload
# into our prefix, then prune to keep only the Python wrapping content.
for component in PythonWrappingRuntimeLibraries Runtime RuntimeLibraries Libraries Unspecified libraries; do
    cmake -DCOMPONENT="${component}" -P "${BUILD_DIR}/cmake_install.cmake" || true
done

# The canonical site-packages path for this Python.
PYSITE="${PREFIX}/lib/python${PY_VER}/site-packages"

# Some ITK / conda-build interactions land the wrapping payload at a
# truncated path (e.g. lib/python3.1 instead of lib/python3.12 for PY_VER=3.12)
# despite the -D PY_SITE_PACKAGES_PATH override. If the glob finds anything
# under a *different* python<X>/site-packages dir, relocate it to the
# canonical PYSITE before the prune step runs.
#
# Skip symlinked python<X> dirs: conda's python package ships e.g.
# `lib/python3.1 -> python3.12` as a compat alias, so the glob matches both
# but they reference the same physical directory.
for candidate in "${PREFIX}"/lib/python*/site-packages; do
    [ -d "${candidate}" ] || continue
    parent="$(dirname "${candidate}")"
    if [ -L "${parent}" ]; then
        echo "Skipping ${candidate} (parent is symlink: $(readlink "${parent}"))"
        continue
    fi
    if [ "${candidate}" != "${PYSITE}" ]; then
        echo "Relocating wrapping payload from ${candidate} to ${PYSITE}"
        mkdir -p "$(dirname "${PYSITE}")"
        if [ -d "${PYSITE}" ]; then
            cp -R "${candidate}/." "${PYSITE}/"
            rm -rf "${candidate}"
        else
            mv "${candidate}" "${PYSITE}"
        fi
        rmdir "${parent}" 2>/dev/null || true
    fi
done

if [ ! -d "${PYSITE}" ]; then
    echo "ERROR: no site-packages content at ${PYSITE}" >&2
    exit 1
fi

# Stash the wrapping payload, wipe everything else, restore.
TMP=$(mktemp -d)
[ -d "${PYSITE}/itk" ]          && mv "${PYSITE}/itk"          "${TMP}/"
[ -f "${PYSITE}/itkConfig.py" ] && mv "${PYSITE}/itkConfig.py" "${TMP}/"

rm -rf "${PREFIX}/lib" "${PREFIX}/bin" "${PREFIX}/include" "${PREFIX}/share"

mkdir -p "${PYSITE}"
[ -d "${TMP}/itk" ]          && mv "${TMP}/itk"          "${PYSITE}/"
[ -f "${TMP}/itkConfig.py" ] && mv "${TMP}/itkConfig.py" "${PYSITE}/"
rmdir "${TMP}" 2>/dev/null || true
