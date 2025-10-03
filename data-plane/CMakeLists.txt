# data-plane/CMakeLists.txt
cmake_minimum_required(VERSION 3.10)
project(DVRDataPlane)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Add executable
add_executable(dvr_data_plane
    src/main.cpp
    src/data_plane.cpp
)

# Link pthread for threading
find_package(Threads REQUIRED)
target_link_libraries(dvr_data_plane Threads::Threads)
