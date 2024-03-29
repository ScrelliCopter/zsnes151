function (zsnes_target_defs_common TARGET)
	target_compile_definitions(${TARGET} PRIVATE
		$<$<CONFIG:Debug>:DEBUG>$<$<CONFIG:Release>:__RELEASE__>)
endfunction()

function (zsnes_target_platform_defs TARGET)
	target_compile_definitions(${TARGET} PRIVATE
		$<$<PLATFORM_ID:Windows>:__WIN32__>
		$<$<PLATFORM_ID:DOS>:__MSDOS__>
		$<$<PLATFORM_ID:Darwin>:__MACOSX__>
		$<$<OR:$<PLATFORM_ID:Linux>,$<PLATFORM_ID:Darwin>>:__UNIXSDL__>)
endfunction()

function (zsnes_target_c_flags TARGET)
	set(ZSNES_GCC_CFLAGS -ffast-math -fomit-frame-pointer -fno-unroll-loops -Wall -Wno-unused)
	set(ZSNES_GCC_CXXFLAGS -fno-rtti)
	set(ZSNES_OSX_CFLAGS -mdynamic-no-pic -mstackrealign -fno-unit-at-a-time)
	set(ZSNES_MSVC_CFLAGS /nologo /EHsc /wd4996)
	set(ZSNES_MSVC_CDEFS _CRT_SECURE_NO_WARNINGS _CRT_SECURE_NO_DEPRECATE _CRT_NONSTDC_NO_DEPRECATE)
	target_compile_definitions(${TARGET} PRIVATE
		$<$<OR:$<COMPILE_LANGUAGE:C>,$<COMPILE_LANGUAGE:CXX>>:$<$<CXX_COMPILER_ID:MSVC>:${ZSNES_MSVC_CDEFS}>>)
	target_compile_options(${TARGET} PRIVATE
		$<$<COMPILE_LANGUAGE:C>:$<$<C_COMPILER_ID:GNU>:${ZSNES_GCC_CFLAGS}>>
		$<$<COMPILE_LANGUAGE:CXX>:$<$<CXX_COMPILER_ID:GNU>:${ZSNES_GCC_CFLAGS} ${ZSNES_GCC_CXXFLAGS}>>
		$<$<AND:$<COMPILE_LANGUAGE:C>,$<COMPILE_LANGUAGE:CXX>>:$<$<PLATFORM_ID:Darwin>:${ZSNES_OSX_CFLAGS}>>
		$<$<COMPILE_LANGUAGE:C>:$<$<C_COMPILER_ID:MSVC>:${ZSNES_MSVC_CFLAGS}>>
		$<$<COMPILE_LANGUAGE:CXX>:$<$<CXX_COMPILER_ID:MSVC>:${ZSNES_MSVC_CFLAGS}>>)
	if (CMAKE_VERSION VERSION_GREATER "3.12")
		set_property(TARGET ${TARGET} PROPERTY CXX_STANDARD 98)
	else()
		target_compile_options(${TARGET} PRIVATE
			$<$<COMPILE_LANGUAGE:CXX>:$<$<CXX_COMPILER_ID:GNU>:-std=c++98>>)
	endif()
	if (CMAKE_VERSION VERSION_GREATER_EQUAL "3.15")
		set_property(TARGET ${TARGET} PROPERTY
			MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
	endif()
endfunction()

function (zsnes_target_nasm_flags TARGET)
	set(ZSNES_NASMFLAGS -O1
		# Old OSX is likely to bindle very old (0.9x) version of NASM that doesn't support this flag
		$<$<NOT:$<PLATFORM_ID:Darwin>>:-w-label-orphan>
		# Workaround for old nasm which only respected includes with trailing slash https://bugzilla.nasm.us/show_bug.cgi?id=3392205
		-I${CMAKE_CURRENT_SOURCE_DIR}/
		#$<$<PLATFORM_ID:DOS>:-f coff>
		#BUG: defines don't seem to touch nasm :(
		$<$<PLATFORM_ID:Windows>:-D__WIN32__>
		$<$<PLATFORM_ID:DOS>:-D__MSDOS__>
		$<$<PLATFORM_ID:Linux>:-DELF>
		$<$<PLATFORM_ID:Darwin>:-D__MACOSX__ -DMACHO>
		$<$<OR:$<PLATFORM_ID:Linux>,$<PLATFORM_ID:Darwin>>:-D__UNIXSDL__>)
	target_compile_options(${TARGET} PRIVATE
		$<$<COMPILE_LANGUAGE:ASM_NASM>:${ZSNES_NASMFLAGS}>)

endfunction()

function (zsnes_source_group)
	set(SOURCE_EXT "c|cpp|asm|psr|rc")
	set(HEADER_EXT "h|hpp|inc|mac")

	set(PREFIX "${ARGV0}")
	if (PREFIX)
		source_group("Source Files/${PREFIX}" REGULAR_EXPRESSION "${PREFIX}/.*\\.(${SOURCE_EXT})$")
		source_group("Header Files/${PREFIX}" REGULAR_EXPRESSION "${PREFIX}/.*\\.(${HEADER_EXT})$")
	else()
		source_group("Source Files" REGULAR_EXPRESSION "\\.(${SOURCE_EXT})$")
		source_group("Header Files" REGULAR_EXPRESSION "\\.(${HEADER_EXT})$")
	endif()
endfunction()

function (zsnes_target_add_parsers)
	cmake_parse_arguments(ARGS "" "TARGET" "SOURCE" ${ARGN})
	foreach (PSR ${ARGS_SOURCE})
		if (CMAKE_VERSION VERSION_LESS "3.14")
			get_filename_component(PSRNAME "${PSR}" NAME_WE)
		elseif (CMAKE_VERSION VERSION_LESS "3.20")
			get_filename_component(PSRNAME "${PSR}" NAME_WLE)
		else()
			cmake_path(GET PSR STEM LAST_ONLY PSRNAME)
		endif()
		get_filename_component(INPUT "${PSR}" REALPATH)
		set(_ARGS 
			$<$<PLATFORM_ID:Windows>:-D__WIN32__>
			$<$<PLATFORM_ID:DOS>:-D__MSDOS__>
			$<$<PLATFORM_ID:Darwin>:-D__MACOSX__>
			$<$<OR:$<PLATFORM_ID:Linux>,$<PLATFORM_ID:Darwin>>:-D__UNIXSDL__>
			$<$<BOOL:OPENGL_FOUND>:-D__OPENGL__>
			-cheader "${PSRNAME}.h" -fname "${PSRNAME}" "${PSRNAME}.c" "${INPUT}")
		if (CMAKE_SYSTEM_NAME STREQUAL "Darwin")
			add_custom_command(OUTPUT "${PSRNAME}.c" "${PSRNAME}.h"
				COMMAND "./parsegen" ARGS ${_ARGS}
				DEPENDS parsegen "${PSR}")
		else()
			add_custom_command(OUTPUT "${PSRNAME}.c" "${PSRNAME}.h"
				COMMAND parsegen ARGS ${_ARGS}
				DEPENDS parsegen "${PSR}")
		endif()
		target_sources(${ARGS_TARGET} PRIVATE "${PSR}" "${PSRNAME}.c" "${PSRNAME}.h")
	endforeach()
	target_include_directories(${ARGS_TARGET} PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
endfunction()
