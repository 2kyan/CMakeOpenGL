cmake_minimum_required(VERSION 3.1)

Project(OpenGLScratch)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
set_property(GLOBAL PROPERTY USE_FOLDERS TRUE)

include(shared)

set(PRJ_GROUP yaml-cpp)
set(VERBOSE OFF)
set(YAML_CPP_BUILD_TESTS OFF)
set(YAML_CPP_INSTALL OFF)
set(BUILD_SHARED_LIBS OFF)
buildExtDep(yaml-cpp "https://github.com/jbeder/yaml-cpp.git" master)
get_property(dirs DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY INCLUDE_DIRECTORIES)
foreach(dir ${dirs})
    message(STATUS "dir='${dir}'")
endforeach()
unset(PRJ_GROUP)
set_property(GLOBAL PROPERTY USE_FOLDERS OFF)

set(LIBROOT $ENV{GITHUB})

include_directories(include)
include_directories(glad/include)
include_directories(${LIBROOT}/glm)
include_directories(${LIBROOT}/glfw/include)

link_directories(${LIBROOT}/glfw/src/Debug)

set(INC 
    include/rslib.h
    include/texture.h
    include/shader.h
)

set(SRC 
    # ${INC}
    src/rslib.cpp
    src/texture.cpp
    src/shader.cpp
    src/main.cpp
    glad/src/glad.c
)

add_executable(OpenGLScratch ${SRC})

target_link_libraries(OpenGLScratch opengl32 glfw3 yaml-cpp)