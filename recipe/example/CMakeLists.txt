# This is the root ITK CMakeLists file.
cmake_minimum_required(VERSION 3.3)


# This project is designed to be built outside the Insight source tree.
project(HelloWorld)

# Find ITK.
find_package(ITK REQUIRED)
include(${ITK_USE_FILE})

add_executable(HelloWorld HelloWorld.cxx )

target_link_libraries(HelloWorld ${ITK_LIBRARIES})
