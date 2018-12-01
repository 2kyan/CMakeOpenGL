#=======================================================================
#   This file is shared.cmake
#
#   shared.cmake is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.

#   This file is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.

#   You should have received a copy of the GNU General Public License
#   along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
#
#=======================================================================
#
#   Descriptions:

#   Notes:

#   Authors:
#       2KYan, 2KYan@outlook.com

#
#=======================================================================
#

cmake_minimum_required(VERSION 3.0.0)

#SET (DYN_OBJS)
#SET (DYN_FILES
#solution
#)
#
#foreach(DYN_FILE ${DYN_FILES}) 
#
#add_custom_command(
#OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/inc/${DYN_FILE}.h
#DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/template/${DYN_FILE}.template ${PROJECT_SOURCE_DIR}/scripts/generator.py
#COMMAND python
#ARGS ${PROJECT_SOURCE_DIR}/scripts/generator.py ${CMAKE_CURRENT_SOURCE_DIR}/template/${DYN_FILE}.template ${CMAKE_CURRENT_BINARY_DIR}/inc/${DYN_FILE}.h
#)
#
#set(DYN_OBJS ${DYN_OBJS} ${CMAKE_CURRENT_BINARY_DIR}/inc/${DYN_FILE}.h)
#
#endforeach(DYN_FILE ${DYN_FILES}) 

if (DEFINED DEV_SHARED_CMAKE_INCLUDED)
    message("shared.cmake has been included! It should only be included once!")
    return()
else()
    set(DEV_SHARED_CMAKE_INCLUDED 1)
endif()

message(${PROJECT_SOURCE_DIR})
set(OUTPUT_BINARY_DIR ${PROJECT_SOURCE_DIR}/build)

###########################################################################################################################
####                                        Function/Macro Overloading                                                 ####
###########################################################################################################################

function(add_library)
    set(CMAKE_PDB_OUTPUT_DIRECTORY ${OUTPUT_BINARY_DIR})
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${OUTPUT_BINARY_DIR})
    #set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${OUTPUT_BINARY_DIR})
    string(TOUPPER ${ARGV1} argv1_upper)
    if (${OUT_OF_SOURCE_BUILD})
        if (UNIX)
            if (argv1_upper STREQUAL "SHARED")
                set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${OUTPUT_BINARY_DIR})
            endif()
        else()
            set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${OUTPUT_BINARY_DIR})
        endif()
        _add_library(${ARGV})
    else()
        _add_library(${ARGV})
        if (argv1_upper STREQUAL "SHARED")
            add_custom_command(
                TARGET ${ARGV0}
                POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E make_directory ${OUTPUT_BINARY_DIR}/$<CONFIGURATION>/
                COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_FILE:${ARGV0}> ${OUTPUT_BINARY_DIR}/$<CONFIGURATION>
                #COMMAND ${CMAKE_COMMAND} -E make_directory ${OUTPUT_BINARY_DIR}/
                #COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_FILE:${ARGV0}> ${OUTPUT_BINARY_DIR}/
            )
        endif()
    endif()
    if (WIN32)
        if ((${PROJECT_NAME} MATCHES "^Solution[5-9].*") OR (${PROJECT_NAME} MATCHES "^TestProj[0-9].*"))
           set_property(TARGET ${ARGV0} PROPERTY STATIC_LIBRARY_FLAGS /WX)
       endif()
       
       if (${PROJECT_NAME} MATCHES "^[NAME].*")
           if (${ARGV0} MATCHES "^(blockA|blockB)$")
               REMOVE_DEFINITIONS(-MP)
               ADD_DEFINITIONS(-MP4)
           endif()
           if (${ARGV0} MATCHES "^(mh)$")
               REMOVE_DEFINITIONS(-MP)
               ADD_DEFINITIONS(-MP1)
           endif()
       endif()
    endif()
    # if (PRJ_GROUP)
        # set_property(TARGET ${ARGV0} PROPERTY FOLDER ${PRJ_GROUP})
    # endif()
endfunction()

function(add_executable)
    set(CMAKE_PDB_OUTPUT_DIRECTORY ${OUTPUT_BINARY_DIR})
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${OUTPUT_BINARY_DIR})
    #set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${OUTPUT_BINARY_DIR})    
    if (${OUT_OF_SOURCE_BUILD})
        set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${OUTPUT_BINARY_DIR})
        _add_executable(${ARGV})
    else()
        _add_executable(${ARGV})
        add_custom_command(
            TARGET ${ARGV0}
            POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E make_directory ${OUTPUT_BINARY_DIR}/$<CONFIGURATION>/
            COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_FILE:${ARGV0}> ${OUTPUT_BINARY_DIR}/$<CONFIGURATION>
            #COMMAND ${CMAKE_COMMAND} -E make_directory ${OUTPUT_BINARY_DIR}/
            #COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_FILE:${ARGV0}> ${OUTPUT_BINARY_DIR}/
        )
    endif()
    # if (PRJ_GROUP)
        # set_property(TARGET ${ARGV0} PROPERTY FOLDER ${PRJ_GROUP})
    # endif()
endfunction()

function(message)
    if (NOT "${CLEAR_MESSAGE}" STREQUAL "1")
        _message(${ARGV})
    endif()
endfunction()

function(add_definitions)
    if (WIN32)
        if (MSVC_VERSION STREQUAL 1500)
            LIST(REMOVE_ITEM ARGV "/W4")
        endif()
     endif()
    _add_definitions(${ARGV})
endfunction()

macro(LIST_FILTER LIST_NAME LIST_VALUE FILTER_REGEX_PATTERN)
    set(LIST_NEW)
    foreach (ITEM ${LIST_VALUE})
        if (${ITEM} MATCHES ${FILTER_REGEX_PATTERN})
            list(APPEND LIST_NEW ${ITEM})
        endif()
    endforeach()
    set(${LIST_NAME} ${LIST_NEW})
endmacro()

macro(project)
    _project(${ARGV})
    message("CMAKE_CXX_COMPILER    = ${CMAKE_CXX_COMPILER}")
    message("CMAKE_CXX_COMPILER_ID = ${CMAKE_CXX_COMPILER_ID}")
    message("PROJECT_SOURCE_DIR    = ${PROJECT_SOURCE_DIR}")
    message("PROJECT_BINARY_DIR    = ${PROJECT_BINARY_DIR}")
    if (${PROJECT_SOURCE_DIR} STREQUAL ${PROJECT_BINARY_DIR})
        if (MSVC)
            execute_process(COMMAND cmake -E tar c ${ARGV0}_saved.tar ${ARGV0}.sln)
            execute_process(COMMAND cmake -E remove -f ${ARGV0}.sln)
        else()
            execute_process(COMMAND cmake -E tar c Makefile_saved.tar Makefile)
            execute_process(COMMAND cmake -E remove -f Makefile)
        endif()
        _message(FATAL_ERROR "No in-source build")
    endif()

    #Only when project has been created, we can use such variables.
    if (${CMAKE_CXX_COMPILER_ID} MATCHES "MSVC")
        #Make release build the same as RelWithDebInfo, so users can debug release version.
        set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /Zi")
        set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /Zi")
        set(CMAKE_EXE_LINKER_FLAGS_RELEASE    "${CMAKE_EXE_LINKER_FLAGS_RELEASE} /debug")
        set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE} /debug")
        set(CMAKE_MODULE_LINKER_FLAGS_RELEASE "${CMAKE_MODULE_LINKER_FLAGS_RELEASE} /debug")
    ADD_DEFINITIONS(-MP)
    elseif(${CMAKE_CXX_COMPILER_ID} MATCHES "Clang" )
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fverbose-asm -std=c++11 ")
    elseif(${CMAKE_CXX_COMPILER_ID} MATCHES "GNU" )
        set(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS} -fverbose-asm")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fverbose-asm")
    endif()

    # check 64 bit
    if(MSVC)
        if(CMAKE_SIZEOF_VOID_P EQUAL 4)
            set( HAVE_64_BIT 0 )
            # Disable SSE instruction to make consitent result from verification wise.
            if (MSVC_VERSION GREATER 1699)
                #vc2012 will issue SSE instruction even for debug mode.
                set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /arch:IA32")
                set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /arch:IA32")
            else()
                set(CMAKE_C_FLAGS_RELEASE "${CMAKE_CXX_FLAGS} /arch:IA32 /MD")
                set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS} /arch:IA32 /MD")
            endif()
        elseif (CMAKE_SIZEOF_VOID_P EQUAL 8)
            MESSAGE("BUILD for 64bit")
            add_definitions(-DBUILD64)
            set( HAVE_64_BIT 1 )
        else ()
            MESSAGE(FATAL_ERROR "Invalid size of void pointer!!!!")
        endif()
        set(CMAKE_C_FLAGS           "${CMAKE_C_FLAGS} /bigobj")
        set(CMAKE_CXX_FLAGS         "${CMAKE_CXX_FLAGS} /bigobj")
        set(CMAKE_C_FLAGS_RELEASE   "${CMAKE_C_FLAGS_RELEASE} /bigobj")
        set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /bigobj")
    else()
        if(BUILD64)
            MESSAGE("BUILD for 64bit")
            add_definitions(-DBUILD64)
            set( HAVE_64_BIT 1 )
            set( GCC_ARCH_FLAG "-m64" )
            set(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS} -ffloat-store")
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ffloat-store")
        else()
            MESSAGE("BUILD for 32bit")
            set( HAVE_64_BIT 0 )
            set( GCC_ARCH_FLAG "-m32 -march=prescott" )
        endif()
    endif()

    # disable some warnings for W4 level
    if(MSVC)
        #pragma warning(disable: 4127)    // disable the warning of comparing against const                
        #pragma warning(disable: 4201)    // disable the warning of old-format struct
        #pragma warning(disable: 4706)    // disable the warning of assignment in condition
        #pragma warning(disable: 4505)    // disable the warning of unreferenced local function
        #pragma warning(disable: 4714)    // disable the warning of function 'function' marked as __forceinline not inlined
        #add_definitions(/wd"4127" /wd"4201" /wd"4706" /wd"4505" /wd"4458") 
        add_definitions(/wd"4714") 
        
        #Disable C4819, which will frequently happen due to copy/merge codes from 3rd party.
        # C4819 occurs when an ANSI source file is compiled on a system with a codepage that cannot represent all characters in the file.
        #add_definitions(/wd"4819")
        
        if (HAVE_64_BIT AND (MSVC_VERSION STREQUAL 1500)) # May need for MSVC 2010 (1600) as well 
            #C4985 :'symbol name': attributes not present on previous declaration.
            add_definitions(/wd"4985") #MS bug: intrin.h conflicts with math.h in VS 2008 64-bit compiler
        endif()
    endif()

    #define user name \\"foo\\"
    if(MSVC)
        if (DEFINED ENV{USERNAME})
            add_definitions(-DUSERNAME=\"$ENV{USERNAME}\")
        else ()
            add_definitions(-DUSERNAME=\"USERNAME_MISSING\")
        endif()
    else()
        if (DEFINED ENV{USER})
            add_definitions(-DUSERNAME=\"$ENV{USER}\")
        else ()
            add_definitions(-DUSERNAME=\"USERNAME_MISSING\")
        endif()
    endif()
    
    if (DEFINED ENV{HLMTEST_SELECT_BLOCK_REGEX})
        set(HLMTEST_SELECT_BLOCK_REGEX_PATTERN "$ENV{HLMTEST_SELECT_BLOCK_REGEX}")
    else()
        set(HLMTEST_SELECT_BLOCK_REGEX_PATTERN ".+")
    endif()
    set(HLMTEST_SELECT_BLOCK_REGEX_PATTERN "^${HLMTEST_SELECT_BLOCK_REGEX_PATTERN}$")
    #message("${HLMTEST_SELECT_BLOCK_REGEX_PATTERN}")
endmacro()

function(conditional_add_subdirectory condition_var)
    if(${condition_var} STREQUAL true)
        add_subdirectory(${ARGN})
    endif ()
endfunction()    

function(conditional_add_dependencies condition_var)
    if(${condition_var} STREQUAL true)
        add_dependencies(${ARGN})
    endif ()
endfunction() 

function(conditional_add_executable condition_var)
    if(${condition_var} STREQUAL true)
        add_executable(${ARGN})
    endif ()
endfunction() 

function(conditional_target_link_libraries condition_var)
    if(${condition_var} STREQUAL true)
        target_link_libraries(${ARGN})
    endif ()
endfunction() 

function(conditional_source_group condition_var)
    if(${condition_var} STREQUAL true)
        source_group(${ARGN})
    endif ()
endfunction() 

set (PCH_EXCLUSIVE_REGEX ".*abc.cpp$|.*def.cpp$|.*ghi.cpp$")

function(GET_EXT INPUT_FILE)
    if (INPUT_FILE MATCHES "\\.")
        get_filename_component(INPUT_FILE_EXT_TMP ${INPUT_FILE} EXT)
        string(TOUPPER ${INPUT_FILE_EXT_TMP} INPUT_FILE_EXT_TMP)
        string(SUBSTRING ${INPUT_FILE_EXT_TMP} 1 1 INPUT_FILE_EXT_TMP)
        set (INPUT_FILE_EXT "${INPUT_FILE_EXT_TMP}" PARENT_SCOPE)
    else ()
        #message (${INPUT_FILE})
        set (INPUT_FILE_EXT "JUNK" PARENT_SCOPE)
    endif ()
endfunction()

function(conditional_add_library cond_var library uncond_list cond_list)
    if(${cond_var} STREQUAL true)
        add_library_PCH(${library} ${uncond_list} ${cond_list})
    else()
        add_library_PCH(${library} ${uncond_list})
    endif ()
endfunction()   

function(ADD_PCH Proj)
    if (DEFINED PCH_header_file_name)
        set(precompiled_header_file_name_with_postfix ${PCH_header_file_name}.h)
    else()
        set(precompiled_header_file_name_with_postfix ${Proj}_shared.h)
    endif()
    ADD_PCH_IMPL("${PROJECT_BINARY_DIR}/${Proj}/src/${Proj}_pch" "inc/${precompiled_header_file_name_with_postfix}" "" ${ARGN})
endfunction()

function(ADD_PCH_IMPL PrecompiledFnNoExt PrecompiledHeaderPath AdditionalFlags)
    get_filename_component(PrecompiledHeader ${PrecompiledHeaderPath} NAME)
    get_filename_component(PrecompiledBinaryDir ${PrecompiledFnNoExt} DIRECTORY)
    get_filename_component(PrecompiledBinaryFn ${PrecompiledFnNoExt} NAME)
    if (${CMAKE_GENERATOR} STREQUAL Ninja)
        SET(PrecompiledBinary "${PrecompiledBinaryDir}/${PrecompiledBinaryFn}.pch")
    else()
        SET(PrecompiledBinary "${PrecompiledBinaryDir}/$(Configuration)/${PrecompiledBinaryFn}.pch")
    endif()
    SET(PrecompiledCXX    "${PrecompiledFnNoExt}.cxx")
    SET(PureSources "")
    set (HeaderString "#include \"${PrecompiledHeader}\"")
    if(EXISTS ${PrecompiledCXX}) 
        file(READ ${PrecompiledCXX} OrigHeaderString)
    endif()
    if (NOT HeaderString STREQUAL OrigHeaderString)
        file(WRITE ${PrecompiledCXX} ${HeaderString})
    endif()
    foreach(INPUT_FILE ${ARGN})
        GET_EXT(${INPUT_FILE} INPUT_FILE_EXT)
        if ((${INPUT_FILE_EXT} STREQUAL "C") AND
                (NOT (INPUT_FILE MATCHES ${PCH_EXCLUSIVE_REGEX})))
            set(PureSources ${PureSources} ${INPUT_FILE})
        endif()
    endforeach()
    
    SET_SOURCE_FILES_PROPERTIES(${PrecompiledCXX}
                                PROPERTIES COMPILE_FLAGS "${AdditionalFlags} /Yc\"${PrecompiledHeader}\" /Ym0x40000000 /Fp\"${PrecompiledBinary}\""
                                           OBJECT_OUTPUTS "${PrecompiledBinary}")
    SET_SOURCE_FILES_PROPERTIES(${PureSources}
                                PROPERTIES COMPILE_FLAGS "${AdditionalFlags} /Yu\"${PrecompiledHeader}\" /Ym0x40000000 /Fp\"${PrecompiledBinary}\""
                                           OBJECT_DEPENDS "${PrecompiledBinary}")  
    SET_PROPERTY(GLOBAL PROPERTY PCHGlobalProperty ${ARGN} ${PrecompiledCXX} ${PrecompiledHeaderPath})
endfunction()


function(add_library_PCH Proj)
    if (0) # Disable PCH check since it's too slow. MSVC will report no "_shared" header error anyway
        set(SRCS "${ARGN}")
        foreach(loop_var IN LISTS SRCS)
            if (NOT (loop_var MATCHES ${PCH_EXCLUSIVE_REGEX}))
                execute_process(COMMAND python ${PROJECT_SOURCE_DIR}/tools/scripts/pch_check.py ${ARGV0} ${loop_var} ${CMAKE_CURRENT_SOURCE_DIR} RESULT_VARIABLE _PCH_CHECK_RESULT)
                if (NOT _PCH_CHECK_RESULT STREQUAL "0")
                    MESSAGE(FATAL_ERROR "${loop_var} has no PCH header file at the beginning")
                else ()
                    # Leave this comment there
                    # MESSAGE("${loop_var} has PCH header file at the beginning")
                endif()
            endif()
        endforeach()
    endif ()
    set (COMPILATION_UNIT_NUM 0)
    if (USE_PCH)
        foreach(INPUT_FILE ${ARGN})
            GET_EXT(${INPUT_FILE} INPUT_FILE_EXT)
            if (${INPUT_FILE_EXT} STREQUAL "C") 
                MATH(EXPR COMPILATION_UNIT_NUM "${COMPILATION_UNIT_NUM}+1")
            endif ()
        endforeach() 
    endif()
    if (USE_PCH AND (${COMPILATION_UNIT_NUM} GREATER 2))
        ADD_PCH(${ARGV})
        GET_PROPERTY(PCH_ALL_FILES GLOBAL PROPERTY PCHGlobalProperty)
        add_library(${Proj} ${PCH_ALL_FILES})
    else()
         add_library(${ARGV})
    endif()
endfunction()

function(add_library_PCH_with_specified_file_name Proj PCH_header_file_name)
    add_library_PCH(${Proj} ${ARGN})
endfunction()

function(add_executable_PCH Proj)
    if (0) # Disable PCH check since it's too slow. MSVC will report no "_shared" header error anyway
        set(SRCS "${ARGN}")
        foreach(loop_var IN LISTS SRCS)
            if (NOT (loop_var MATCHES ${PCH_EXCLUSIVE_REGEX}))
                execute_process(COMMAND python ${PROJECT_SOURCE_DIR}/tools/scripts/pch_check.py ${ARGV0} ${loop_var} ${CMAKE_CURRENT_SOURCE_DIR} RESULT_VARIABLE _PCH_CHECK_RESULT)
                if (NOT _PCH_CHECK_RESULT STREQUAL "0")
                    MESSAGE(FATAL_ERROR "${loop_var} has no PCH header file at the beginning")
                else ()
                    # Leave this comment there
                    # MESSAGE("${loop_var} has PCH header file at the beginning")
                endif()
            endif()
        endforeach()
    endif ()
    set (COMPILATION_UNIT_NUM 0)
    if (USE_PCH)
        foreach(INPUT_FILE ${ARGN})
            GET_EXT(${INPUT_FILE} INPUT_FILE_EXT)
            if (${INPUT_FILE_EXT} STREQUAL "C") 
                MATH(EXPR COMPILATION_UNIT_NUM "${COMPILATION_UNIT_NUM}+1")
            endif ()
        endforeach() 
    endif()
    if (USE_PCH AND (${COMPILATION_UNIT_NUM} GREATER 2))
        ADD_PCH(${ARGV})
        GET_PROPERTY(PCH_ALL_FILES GLOBAL PROPERTY PCHGlobalProperty)
        add_executable(${Proj} ${PCH_ALL_FILES})
    else()
        add_executable(${ARGV})
    endif()
endfunction()

function(add_executable_PCH_with_specified_file_name Proj PCH_header_file_name)
    add_executable_PCH(${Proj} ${ARGN})
endfunction()

###########################################################################################################################
####                                        Definition/Compile Option                                                  ####
###########################################################################################################################

if (WIN32)
    ADD_DEFINITIONS(-DWIN32)
    ADD_DEFINITIONS(-D_CRT_SECURE_NO_WARNINGS -D_CRT_SECURE_NO_DEPRECATE -DENABLE_DUMP_CALLSTACK=1 -EHa)
    # to suppress all asserts popups
    if (NO_POPUP STREQUAL true)
        ADD_DEFINITIONS(-DNO_POPUP)
    endif (NO_POPUP STREQUAL true)

    if (NOT HAVE_64_BIT)
        ADD_DEFINITIONS(/Oy-)
    endif ()
    #ADD_DEFINITIONS(/W4)    
    
    SET(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} /NODEFAULTLIB:LIBCMT.lib /WX")
    SET(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} /WX")
    SET(CMAKE_EXE_LINKER_FLAGS    "${CMAKE_EXE_LINKER_FLAGS}    /WX")
  
else ()
    # this is to ensure we have the same directory
    # hierarchy in Windows as well as Linux
    set (CMAKE_LIBRARY_OUTPUT_DIRECTORY $ENV{BUILD_CONFIG})
    set (CMAKE_ARCHIVE_OUTPUT_DIRECTORY $ENV{BUILD_CONFIG})
    set (CMAKE_RUNTIME_OUTPUT_DIRECTORY $ENV{BUILD_CONFIG})
    set (CMAKE_BINARY_OUTPUT_DIRECTORY $ENV{BUILD_CONFIG})

    ADD_DEFINITIONS(-g -DLINUX -fPIC ${GCC_ARCH_FLAG} -DqLittleEndian)

    if (BUILD_CONFIG STREQUAL Release)
        ADD_DEFINITIONS(-O3 -DNDEBUG)
    endif (BUILD_CONFIG STREQUAL Release)

    #SET(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--fatal-warnings")
    #SET(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} -Wl,--fatal-warnings")
    #SET(CMAKE_EXE_LINKER_FLAGS    "${CMAKE_EXE_LINKER_FLAGS} -Wl,--fatal-warnings")

    ADD_DEFINITIONS(-Wswitch -Wsequence-point -Wno-write-strings -Wuninitialized -Winit-self)
    ADD_DEFINITIONS(-fms-extensions)

endif ()  

if( MSVC_STATIC_LINKING STREQUAL "TRUE" )
    set(CMAKE_USER_MAKE_RULES_OVERRIDE c_flag_overrides)
    set(CMAKE_USER_MAKE_RULES_OVERRIDE_CXX cxx_flag_overrides)
    #set(CMAKE_USER_MAKE_RULES_OVERRIDE ${CMAKE_CURRENT_SOURCE_DIR}/c_flag_overrides.cmake)
    #set(CMAKE_USER_MAKE_RULES_OVERRIDE_CXX ${CMAKE_CURRENT_SOURCE_DIR}/cxx_flag_overrides.cmake)
endif()

# Replace /MDd with /MD and /MTd with /MT if requested.
set ( OVERRIDE_MD_WITH_MT $ENV{OVERRIDE_MD_WITH_MT} )
if (OVERRIDE_MD_WITH_MT STREQUAL true)
foreach(flag_var
        CMAKE_CXX_FLAGS CMAKE_CXX_FLAGS_DEBUG CMAKE_CXX_FLAGS_RELEASE
        CMAKE_CXX_FLAGS_MINSIZEREL CMAKE_CXX_FLAGS_RELWITHDEBINFO
        CMAKE_C_FLAGS   CMAKE_C_FLAGS_DEBUG   CMAKE_C_FLAGS_RELEASE
        CMAKE_C_FLAGS_MINSIZEREL CMAKE_C_FLAGS_RELWITHDEBINFO
        )
    if(${flag_var} MATCHES "/MD")
        string(REGEX REPLACE "/MD" "/MT" ${flag_var} "${${flag_var}}")
    endif(${flag_var} MATCHES "/MD")
endforeach(flag_var)
endif (OVERRIDE_MD_WITH_MT STREQUAL true)

#set(CMAKE_DEBUG_POSTFIX "d" CACHE STRING "Generate debug library name with a postfix.")

###########################################################################################################################
####                                            External Resources                                                     ####
###########################################################################################################################
macro(buildExtDep) 
    if (${ARGC} LESS 2)
        return()
    endif()
    #Dependet Library
    string(TOUPPER ${ARGV0} DLIBNAME)
    set(EXTERNAL_${DLIBNAME}_SRC ${CMAKE_BINARY_DIR}/${ARGV0}-src)
    set(EXTERNAL_${DLIBNAME}_DOWNLOAD ${CMAKE_BINARY_DIR}/${ARGV0}-download)
    set(EXTERNAL_${DLIBNAME}_BUILD ${CMAKE_BINARY_DIR}/${ARGV0}-build)

    message("${DLIBNAME}")
    message("${EXTERNAL_${DLIBNAME}_SRC}")
    message("${EXTERNAL_${DLIBNAME}_DOWNLOAD}")
    message("${EXTERNAL_${DLIBNAME}_BUILD}")
    file(WRITE ${EXTERNAL_${DLIBNAME}_DOWNLOAD}/CMakeLists.txt 
    "
    cmake_minimum_required(VERSION 3.0.0)

    project(${ARGV0}-download NONE)

    include(ExternalProject)
    ExternalProject_Add(${ARGV0}.build
        GIT_REPOSITORY    ${ARGV1}
        GIT_TAG           ${ARGV2}
        SOURCE_DIR        \"${EXTERNAL_${DLIBNAME}_SRC}\"
        BINARY_DIR        \"${EXTERNAL_${DLIBNAME}_BUILD}\"
        CONFIGURE_COMMAND \"\"
        BUILD_COMMAND     \"\"
        INSTALL_COMMAND   \"\"
        TEST_COMMAND      \"\"
    )
    "
    )

    #configure_file(config/shared.cmake.in ${CMAKE_BINARY_DIR}/shared-download/CMakeLists.txt)
    execute_process(COMMAND ${CMAKE_COMMAND} -G "${CMAKE_GENERATOR}" .
    RESULT_VARIABLE result
    WORKING_DIRECTORY ${EXTERNAL_${DLIBNAME}_DOWNLOAD})
    if(result)
    message(FATAL_ERROR "CMake step for ${ARGV0} failed: ${result}")
    endif()
    execute_process(COMMAND ${CMAKE_COMMAND} --build .
    RESULT_VARIABLE result
    WORKING_DIRECTORY ${EXTERNAL_${DLIBNAME}_DOWNLOAD})
    if(result)
    message(FATAL_ERROR "Build step for ${ARGV0} failed: ${result}")
    endif()

    include_directories(${EXTERNAL_${DLIBNAME}_SRC}/include)

    add_subdirectory(${EXTERNAL_${DLIBNAME}_SRC} ${EXTERNAL_${DLIBNAME}_BUILD})
endmacro()

