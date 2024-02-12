set(CMAKE_SYSTEM_NAME "Darwin")

# Force 32-bit build
set(CMAKE_SYSTEM_PROCESSOR "i386")
set(CMAKE_OSX_ARCHITECTURES "i386")
set(CMAKE_ASM_NASM_OBJECT_FORMAT "macho")

# CMAKE_OSX_ARCHITECTURES is not a strong enough suggestion on some generators... therefore
set(CMAKE_C_FLAGS_INIT "-arch i386")
set(CMAKE_CXX_FLAGS_INIT "-arch i386")

# Hack to stop CMake's crappy NASM support from adding
#  -MD & -MT to old NASM (which doesn't understand those flags)
#set(CMAKE_DEPFILE_FLAGS_ASM_NASM "")
#set(CMAKE_DEPENDS_USE_COMPILER FALSE)
set(CMAKE_ASM_NASM_COMPILER_ID "YASM")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# If you'd prefer cmake to find & link ie. system zlib
#list(APPEND CMAKE_IGNORE_PATH /opt/homebrew)
#list(APPEND CMAKE_IGNORE_PATH /opt/homebrew/include)
#list(APPEND CMAKE_IGNORE_PATH /opt/homebrew/lib)
#list(APPEND CMAKE_IGNORE_PATH /usr/local)
#list(APPEND CMAKE_IGNORE_PATH /opt/local)
