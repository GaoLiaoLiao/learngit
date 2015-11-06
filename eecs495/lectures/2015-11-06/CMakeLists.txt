cmake_minimum_required(VERSION 3.3)
project(2015-11-06 CXX)

enable_testing()

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14")

include_directories(${CMAKE_SOURCE_DIR}/src)
include_directories(${CMAKE_SOURCE_DIR}/../2015-11-03/3rdparty)
include_directories(${CMAKE_SOURCE_DIR}../2015-11-03/3rdparty/unittest-cpp)

add_subdirectory(src)
add_subdirectory(tests)
add_subdirectory(${CMAKE_SOURCE_DIR}/../2015-11-03/3rdparty
		 3rdparty)
