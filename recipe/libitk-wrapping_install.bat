set BUILD_DIR=%SRC_DIR%\bld

REM Sweep all components that may carry wrapping payload, then prune.
for %%c in (PythonWrappingRuntimeLibraries Runtime RuntimeLibraries Libraries Unspecified libraries) do (
    cmake -DCOMPONENT=%%c -P %BUILD_DIR%\cmake_install.cmake
)

REM Stash wrapping payload, wipe everything else, restore.
set PYSITE=%LIBRARY_PREFIX%\Lib\site-packages
set STASH=%TEMP%\libitk-wrapping-stash
if exist "%STASH%" rmdir /S /Q "%STASH%"
mkdir "%STASH%"
if exist "%PYSITE%\itk"          move "%PYSITE%\itk"          "%STASH%\itk"
if exist "%PYSITE%\itkConfig.py" move "%PYSITE%\itkConfig.py" "%STASH%\itkConfig.py"

if exist "%LIBRARY_PREFIX%\Lib"     rmdir /S /Q "%LIBRARY_PREFIX%\Lib"
if exist "%LIBRARY_PREFIX%\bin"     rmdir /S /Q "%LIBRARY_PREFIX%\bin"
if exist "%LIBRARY_PREFIX%\include" rmdir /S /Q "%LIBRARY_PREFIX%\include"
if exist "%LIBRARY_PREFIX%\share"   rmdir /S /Q "%LIBRARY_PREFIX%\share"

mkdir "%PYSITE%"
if exist "%STASH%\itk"          move "%STASH%\itk"          "%PYSITE%\itk"
if exist "%STASH%\itkConfig.py" move "%STASH%\itkConfig.py" "%PYSITE%\itkConfig.py"
rmdir /Q "%STASH%" 2>nul
