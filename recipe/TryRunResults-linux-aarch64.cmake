# This file presets TRY_RUN() results for cross-compilation targeting linux-aarch64.
# It was derived from TryRunResults-osx-arm64.cmake with values appropriate for
# Linux aarch64 (no SSE2, IEEE754 standard double arithmetic, POSIX LFS, clock_gettime).
#
# To regenerate: perform a native or cross-compile cmake configure of ITK for
# linux-aarch64 in cross-compilation mode; cmake will produce this file automatically.
# See: https://cmake.org/cmake/help/latest/variable/CMAKE_CROSSCOMPILING.html


# DOUBLE_CONVERSION_CORRECT_DOUBLE_OPERATIONS
#    Exit code 1 means double conversion operations are correct (no workaround needed).
#    aarch64 uses IEEE 754 standard doubles — same as osx-arm64.
set( DOUBLE_CONVERSION_CORRECT_DOUBLE_OPERATIONS
     1
     CACHE STRING "Result from TRY_RUN" FORCE)

# VCL_HAS_LFS
#    Exit code 0 means large file support (LFS) is available.
#    Linux aarch64 always supports LFS via 64-bit off_t.
set( VCL_HAS_LFS
     0
     CACHE STRING "Result from TRY_RUN" FORCE)

# VXL_HAS_SSE2_HARDWARE_SUPPORT
#    Exit code 0 means SSE2 is NOT available (0 = success for "has no SSE2").
#    aarch64 has no SSE2 (x86-specific instruction set).
set( VXL_HAS_SSE2_HARDWARE_SUPPORT
     0
     CACHE STRING "Result from TRY_RUN" FORCE)

# VXL_SSE2_HARDWARE_SUPPORT_POSSIBLE
#    Exit code 0 means SSE2 runtime support is not possible.
#    aarch64 has no SSE2.
set( VXL_SSE2_HARDWARE_SUPPORT_POSSIBLE
     0
     CACHE STRING "Result from TRY_RUN" FORCE)

# QNANHIBIT_VALUE
#    Exit code 1 means the high bit of the mantissa in a quiet NaN is set.
#    IEEE 754 standard; true on aarch64 (same as osx-arm64 and x86_64).
set( QNANHIBIT_VALUE
     1
     CACHE STRING "Result from TRY_RUN" FORCE)
set( QNANHIBIT_VALUE__TRYRUN_OUTPUT
     ""
     CACHE STRING "Result from TRY_RUN" FORCE)

# HAVE_CLOCK_GETTIME_RUN
#    Exit code 0 means clock_gettime() is available and works.
#    All modern Linux platforms support POSIX clock_gettime().
set( HAVE_CLOCK_GETTIME_RUN
     0
     CACHE STRING "Result from TRY_RUN" FORCE)
