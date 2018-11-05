cmake_minimum_required(VERSION 3.0)

Project(OpenGLScratch)

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
    ${INC}
    src/rslib.cpp
    src/texture.cpp
    src/shader.cpp
    src/main.cpp
    glad/src/glad.c
)

add_executable(OpenGLScratch ${SRC})

target_link_libraries(OpenGLScratch opengl32 glfw3)