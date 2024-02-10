cmake_minimum_required(VERSION "3.11" FATAL_ERROR)
if (CMAKE_VERSION VERSION_GREATER_EQUAL "3.15")
	cmake_policy(SET CMP0091 NEW)
endif()
project(zsnes LANGUAGES C CXX ASM_NASM)

# Enable Hot Reload for MSVC compilers if supported
if (POLICY CMP0141)
	cmake_policy(SET CMP0141 NEW)
	set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "$<IF:$<AND:$<C_COMPILER_ID:MSVC>,$<CXX_COMPILER_ID:MSVC>>,$<$<CONFIG:Debug,RelWithDebInfo>:EditAndContinue>,$<$<CONFIG:Debug,RelWithDebInfo>:ProgramDatabase>>")
endif()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)


option(DEBUGGER "Enable the debugger (links curses)" OFF)
option(JMA "Enable support for NSRT compressed ROMs" ON)

option(USE_SYSTEM_ZLIB "Use the system ZLib instead of the bundled one" ${UNIX})
option(USE_SYSTEM_PNG "Use the system LIBPNG instead of the bundled one" OFF)

set_property(GLOBAL PROPERTY USE_FOLDERS ON)

if (USE_SYSTEM_ZLIB)
	find_package(ZLIB REQUIRED)
else()
	add_subdirectory(ext/zlib)
endif()

if (USE_SYSTEM_PNG)
	find_package(PNG REQUIRED)
else()
	add_subdirectory(ext/lpng12)
endif()

add_subdirectory(src)

if (CMAKE_GENERATOR MATCHES "Visual Studio")
	set_property(DIRECTORY ${CMAKE_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT zsnes)
	set(CMAKE_SUPPRESS_REGENERATION TRUE)
endif()
