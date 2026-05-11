set BUILD_DIR=%SRC_DIR%\bld
cmake -DCOMPONENT=Development -P %BUILD_DIR%\cmake_install.cmake
cmake -DCOMPONENT=DebugDevel -P %BUILD_DIR%\cmake_install.cmake
cmake -DCOMPONENT=cpplibraries  -P %BUILD_DIR%\cmake_install.cmake
cmake -DCOMPONENT=Headers -P %BUILD_DIR%\cmake_install.cmake

for /f "tokens=1,2 delims=." %%a in ("%PKG_VERSION%") do set ITK_VERSION_MM=%%a.%%b
set ITK_CMAKE_DEST=%LIBRARY_PREFIX%\lib\cmake\ITK-%ITK_VERSION_MM%
set KWSTYLE_DEST=%LIBRARY_PREFIX%\lib\cmake\Utilities\KWStyle
if not exist "%ITK_CMAKE_DEST%" mkdir "%ITK_CMAKE_DEST%"
if not exist "%KWSTYLE_DEST%" mkdir "%KWSTYLE_DEST%"
REM Single-line set: cmd.exe's multi-line `for %%f in (^ ... ^)` is fragile,
REM as caret continuations across many lines can drop entries or fail to parse.
for %%f in (ITKModuleExternal.cmake ITKModuleMacros.cmake ITKModuleDoxygen.cmake ITKModuleHeaderTest.cmake ITKModuleKWStyleTest.cmake ITKModuleCPPCheckTest.cmake ITKModuleTest.cmake ITKExternalData.cmake ITKDownloadSetup.cmake ITKInitializeBuildType.cmake ExternalData.cmake ExternalData_config.cmake.in ITKModuleInfo.cmake.in ITKKWStyleConfig.cmake.in CppcheckTargets.cmake TopologicalSort.cmake) do (
    copy /Y "%SRC_DIR%\CMake\%%f" "%ITK_CMAKE_DEST%\%%f"
    if errorlevel 1 exit 1
)
copy /Y "%SRC_DIR%\Utilities\KWStyle\BuildKWStyle.cmake" "%KWSTYLE_DEST%\BuildKWStyle.cmake"
if errorlevel 1 exit 1
copy /Y "%SRC_DIR%\Utilities\KWStyle\KWStyle.cmake" "%KWSTYLE_DEST%\KWStyle.cmake"
if errorlevel 1 exit 1

set MAINT_DEST=%LIBRARY_PREFIX%\lib\cmake\Utilities\Maintenance
if not exist "%MAINT_DEST%" mkdir "%MAINT_DEST%"
copy /Y "%SRC_DIR%\Utilities\Maintenance\BuildHeaderTest.py" "%MAINT_DEST%\BuildHeaderTest.py"
if errorlevel 1 exit 1
