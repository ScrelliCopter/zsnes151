#cmake_minimum_required(VERSION 2.4.3)
set(CMAKE_ALLOW_LOOSE_LOOP_CONSTRUCTS true)

project(libpng C)
enable_testing()

# Copyright (C) 2007-2010 Glenn Randers-Pehrson

# This code is released under the libpng license.
# For conditions of distribution and use, see the disclaimer
# and license in png.h

set(PNGLIB_MAJOR 1)
set(PNGLIB_MINOR 2)
set(PNGLIB_RELEASE 59)
set(PNGLIB_NAME libpng${PNGLIB_MAJOR}${PNGLIB_MINOR})
set(PNGLIB_VERSION ${PNGLIB_MAJOR}.${PNGLIB_MINOR}.${PNGLIB_RELEASE})

if(NOT WIN32)
  find_library(M_LIBRARY
    NAMES m
    PATHS /usr/lib /usr/local/lib
  )
  if(NOT M_LIBRARY)
    message(STATUS
      "math library 'libm' not found - floating point support disabled")
  endif()
else()
  # not needed on windows
  set(M_LIBRARY "")
endif()

# COMMAND LINE OPTIONS
option(PNG_NO_CONSOLE_IO "FIXME" YES)
option(PNG_NO_STDIO      "FIXME" NO)
option(PNG_DEBUG         "Build with debug output" NO)
option(PNGARG            "FIXME" YES)
#TODO:
# PNG_CONSOLE_IO_SUPPORTED

# maybe needs improving, but currently I don't know when we can enable what :)
set(png_asm_tmp "OFF")
if(NOT WIN32)
  find_program(uname_executable NAMES uname PATHS /bin /usr/bin /usr/local/bin)
  if(uname_executable)
    exec_program(${uname_executable}
                 ARGS --machine OUTPUT_VARIABLE uname_output)
    if("uname_output" MATCHES "^.*i[1-9]86.*$")
      set(png_asm_tmp "ON")
    else("uname_output" MATCHES "^.*i[1-9]86.*$")
      set(png_asm_tmp "OFF")
    endif("uname_output" MATCHES "^.*i[1-9]86.*$")
  endif(uname_executable)
else()
  # this env var is normally only set on win64
  set(TEXT "ProgramFiles(x86)")
  if("$ENV{${TEXT}}" STREQUAL "")
    set(png_asm_tmp "ON")
  endif("$ENV{${TEXT}}" STREQUAL "")
endif()

# SET LIBNAME
set(PNG_LIB_NAME png${PNGLIB_MAJOR}${PNGLIB_MINOR})

# to distinguish between debug and release lib
set(CMAKE_DEBUG_POSTFIX "d")


# OUR SOURCES
set(libpng_sources
  png.h
  pngconf.h
  png.c
  pngerror.c
  pngget.c
  pngmem.c
  pngpread.c
  pngread.c
  pngrio.c
  pngrtran.c
  pngrutil.c
  pngset.c
  pngtrans.c
  pngwio.c
  pngwrite.c
  pngwtran.c
  pngwutil.c
)
set(pngtest_sources
  pngtest.c
)

set(PNG_LIB_NAME_STATIC ${PNG_LIB_NAME}_static)
add_library(${PNG_LIB_NAME_STATIC} STATIC ${libpng_sources})
add_library(PNG::PNG ALIAS ${PNG_LIB_NAME_STATIC})
target_include_directories(${PNG_LIB_NAME_STATIC} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(${PNG_LIB_NAME_STATIC} ZLIB::ZLIB)
if(MSVC)
  # msvc does not append 'lib' - do it here to have consistent name
  set_target_properties(${PNG_LIB_NAME_STATIC} PROPERTIES PREFIX "lib")
endif()

target_compile_definitions(${PNG_LIB_NAME_STATIC} PRIVATE PNG_CONFIGURE_LIBPNG)

if(_AIX)
  target_compile_definitions(${PNG_LIB_NAME_STATIC} PRIVATE _ALL_SOURCE)
endif(_AIX)

if(MSVC)
  target_compile_definitions(${PNG_LIB_NAME_STATIC} PRIVATE PNG_NO_MODULEDEF -D_CRT_SECURE_NO_DEPRECATE)
endif(MSVC)

target_compile_definitions(${PNG_LIB_NAME_STATIC} PRIVATE LIBPNG_NO_MMX)
target_compile_definitions(${PNG_LIB_NAME_STATIC} PRIVATE PNG_NO_MMX_CODE)


if(PNG_CONSOLE_IO_SUPPORTED)
  target_compile_definitions(${PNG_LIB_NAME_STATIC} PRIVATE PNG_CONSOLE_IO_SUPPORTED)
endif()

if(PNG_NO_CONSOLE_IO)
  target_compile_definitions(${PNG_LIB_NAME_STATIC} PRIVATE PNG_NO_CONSOLE_IO)
endif()

if(PNG_NO_STDIO)
  target_compile_definitions(${PNG_LIB_NAME_STATIC} PRIVATE PNG_NO_STDIO)
endif()

if(PNG_DEBUG)
  target_compile_definitions(${PNG_LIB_NAME_STATIC} PRIVATE PNG_DEBUG)
endif()

if(NOT M_LIBRARY AND NOT WIN32)
  target_compile_definitions(${PNG_LIB_NAME_STATIC} PRIVATE PNG_NO_FLOATING_POINT_SUPPORTED)
endif()

# SET UP LINKS
if(NOT WIN32)
  # that's uncool on win32 - it overwrites our static import lib...
  set_target_properties(${PNG_LIB_NAME_STATIC} PROPERTIES
    OUTPUT_NAME ${PNG_LIB_NAME}
    CLEAN_DIRECT_OUTPUT 1)
endif()
