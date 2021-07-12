set BUILD_DIR=%SRC_DIR%\bld
mkdir %BUILD_DIR%
cd %BUILD_DIR%

SET CXX_FLAGS="%CXX_FLAGS% /MP"

REM Configure Step
cmake -G "Ninja" ^
    -D BUILD_SHARED_LIBS:BOOL=ON ^
    -D BUILD_TESTING:BOOL=OFF ^
    -D BUILD_EXAMPLES:BOOL=OFF ^
    -D ITK_USE_SYSTEM_EXPAT:BOOL=OFF ^
    -D ITK_USE_SYSTEM_JPEG:BOOL=ON ^
    -D ITK_USE_SYSTEM_PNG:BOOL=ON ^
    -D ITK_USE_SYSTEM_TIFF:BOOL=ON ^
    -D ITK_USE_SYSTEM_EIGEN:BOOL=ON ^
    -D ITK_USE_SYSTEM_ZLIB:BOOL=OFF ^
    -D ITK_USE_KWSTYLE:BOOL=OFF ^
    -D ITK_BUILD_DEFAULT_MODULES:BOOL=ON ^
    -D Module_ITKReview:BOOL=ON ^
    -D Module_SimpleITKFilters=ON ^
    -D Module_ITKTBB:BOOL=ON ^
    -D Module_MGHIO:BOOL=ON ^
    -D Module_GenericLabelInterpolator:BOOL=ON ^
    -D Module_AdaptiveDenoising:BOOL=ON ^
    -D "ITK_DEFAULT_THREADER:STRING=Pool" ^
    -D "CMAKE_SYSTEM_PREFIX_PATH:PATH=%LIBRARY_PREFIX%" ^
    -D "CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%" ^
    -D CMAKE_BUILD_TYPE:STRING=RELEASE ^
    "%SRC_DIR%"

if errorlevel 1 exit 1

REM Build step
cmake --build  . --config Release
if errorlevel 1 exit 1

REM Install step

if errorlevel 1 exit 1
