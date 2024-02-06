include(ZSNESHelpers)

find_package(ZLIB REQUIRED)
find_package(PNG REQUIRED)

if (MINGW)
	add_executable(objfix objfix.c)
	zsnes_target_defs_common(objfix)
endif()

function (zsnes_objfix TARGET)
	if (MINGW)
		add_custom_command(TARGET zsnes POST_BUILD
			COMMAND objfix
			ARGS $<TARGET_FILE:zsnes>
			DEPENDS objfix)
	endif()
endfunction()

if (CMAKE_VERSION VERSION_LESS "3.5")
	include(CMakeParseArguments)
endif()

add_executable(parsegen parsegen.cpp)
target_link_libraries(parsegen ZLIB::ZLIB)
zsnes_target_defs_common(parsegen)
zsnes_target_c_flags(parsegen)


add_executable(zsnes)
if (DEBUGGER)
	find_package(Curses REQUIRED)
	target_sources(zsnes PRIVATE
		# macros.mac asm_call.h zpath.h jma/zsnesjma.h zip/zunzip.h
		debugasm.asm debugger.c)
	target_include_directories(zsnes PRIVATE ${CURSES_INCLUDE_DIRS})
	target_link_libraries(zsnes ${CURSES_LIBRARIES})
else()
	target_compile_definitions(zsnes PRIVATE NO_DEBUGGER)
	target_compile_options(zsnes PRIVATE
		$<$<COMPILE_LANGUAGE:ASM_NASM>:-DNO_DEBUGGER>)
endif()
target_sources(zsnes PRIVATE
	# jma/zsnesjma.h zip/zunzip.h cpu/memtable.h mmlib/mm.h win/safelib.h win/lib.h
	argv.h
	asm_call.h
	macros.mac
	numconv.h
	gblhdr.h
	gblvars.h
	endmem.asm
	init.asm
	initc.c
	patch.c
	ui.c
	vcache.asm
	version.c
	zmovie.c zmovie.h
	zstate.c
	zloader.c zloader.h
	zpath.c zpath.h
	ztimec.c
	ztime.asm)
zsnes_target_add_parsers(TARGET zsnes SOURCE
	cfg.psr
	md.psr
	input.psr)
zsnes_source_group()
target_include_directories(zsnes PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

target_sources(zsnes PRIVATE
	# macros.mac cpu/regs.mac cpu/regsw.mac
	chips/7110proc.asm
	chips/c4emu.c chips/c4proc.asm
	chips/dsp1emu.c chips/dsp1proc.asm
	chips/dsp2proc.asm
	chips/dsp3emu.c chips/dsp3proc.asm
	chips/dsp4emu.c chips/dsp4proc.asm
	chips/fxemu2.asm chips/fxemu2.mac
	chips/fxemu2b.asm chips/fxemu2b.mac
	chips/fxemu2c.asm chips/fxemu2c.mac
	chips/fxtable.asm
	chips/obc1emu.c chips/obc1proc.asm
	chips/sa1proc.asm chips/sa1regs.asm
	chips/sdd1emu.c
	chips/seta10.c
	chips/seta11.c
	chips/sfxproc.asm
	chips/st10proc.asm
	chips/st11proc.asm)
zsnes_source_group(chips)

target_sources(zsnes PRIVATE
	# macros.mac gblvars.h
	cpu/regs.mac cpu/regsw.mac
	cpu/dma.asm
	cpu/dsp.asm cpu/dspproc.asm cpu/firtable.inc
	cpu/execute.asm cpu/executec.c
	cpu/irq.asm
	cpu/memory.asm
	cpu/memtable.c cpu/memtable.h
	cpu/spc700.asm cpu/spcaddr.inc cpu/spcdef.inc
	cpu/stable.asm cpu/s65816d.inc cpu/saddress.inc cpu/saddrni.inc cpu/se65816.inc
	cpu/table.asm cpu/65816d.inc cpu/address.inc cpu/addrni.inc cpu/e65816.inc cpu/regs.inc cpu/regsw.inc
	cpu/tablec.asm cpu/65816dc.inc cpu/e65816c.inc)
zsnes_source_group(cpu)

target_sources(zsnes PRIVATE
	effects/burn.c
	effects/smoke.c
	effects/water.c effects/fixsin.h)
zsnes_source_group(effects)

target_sources(zsnes PRIVATE
	# macros.mac asm_call.h cfg.h md.h zloader.h zpath.h dos/lib.h jma/zsnesjma.h win/lib.h zip/zunzip.h input.h
	gui/gui.asm gui/guicheat.inc gui/guicombo.inc gui/guikeys.inc gui/guimisc.inc gui/guimouse.inc gui/guitools.inc gui/guiwindp.inc
	gui/guifuncs.c
	gui/menu.asm)
zsnes_source_group(gui)
target_include_directories(zsnes PRIVATE
	# Hack for gui/guifuncs.c
	${CMAKE_CURRENT_BINARY_DIR}/gui)

if (JMA)
	target_sources(zsnes PRIVATE
		jma/7z.h
		jma/aribitcd.h
		jma/ariconst.h
		jma/btreecd.h
		jma/iiostrm.h
		jma/inbyte.h
		jma/lencoder.h
		jma/litcoder.h
		jma/lzma.h
		jma/lzmadec.h
		jma/portable.h
		jma/rcdefs.h
		jma/rngcoder.h
		jma/winout.h
		jma/crc32.h
		jma/jma.h
		jma/7zlzma.cpp
		jma/crc32.cpp
		jma/iiostrm.cpp
		jma/inbyte.cpp
		jma/jma.cpp
		jma/lzma.cpp
		jma/lzmadec.cpp
		jma/winout.cpp
		jma/zsnesjma.cpp jma/zsnesjma.h)
	zsnes_source_group(jma)
else()
	target_compile_definitions(zsnes PRIVATE NO_JMA)
	target_compile_options(zsnes PRIVATE
		$<$<COMPILE_LANGUAGE:ASM_NASM>:-DNO_JMA>)
endif()


target_sources(zsnes PRIVATE
	# macros.h zpath.h
	video/vidmacro.mac
	video/makev16b.asm
	video/makev16t.asm
	video/makevid.asm
	video/mode7.mac
	video/mode7.asm
	video/mode716.asm video/mode716.mac
	video/mode716b.asm
	video/mode716d.asm
	video/mode716e.asm
	video/mode716t.asm
	video/mode7ext.asm
	video/mv16tms.asm
	video/newgfx.mac video/newgfx2.mac video/newg16wn.mac
	video/newg162.mac video/newgfx16.mac
	video/newg162.asm 
	video/newgfx.asm 
	video/newgfx16.asm
	video/newgfx2.asm 
	video/m716text.asm
	video/procvid.asm video/2xsaimmx.inc video/copyvid.inc
	video/procvidc.c)
if (CMAKE_SYSTEM_NAME STREQUAL "Windows" OR CMAKE_SYSTEM_NAME STREQUAL "Linux")
	target_sources(zsnes PRIVATE
		# macros.mac
		video/2xsaiw.asm
		video/hq2x16.asm
		video/hq2x32.asm
		video/hq3x16.asm
		video/hq3x32.asm
		video/hq4x16.asm
		video/hq4x32.asm
		video/copyvwin.asm
		video/ntsc.c video/ntsc.h
		video/sw_draw.asm)
endif()
zsnes_source_group(video)

target_sources(zsnes PRIVATE
	# numconv.h zpath.h jma/zsnesjma.h zip/zunzip.h
	zip/zunzip.h
	zip/unzip.c
	zip/zpng.c)
zsnes_source_group(zip)

target_link_libraries(zsnes ZLIB::ZLIB PNG::PNG)

if (CMAKE_SYSTEM_NAME STREQUAL "Windows")
	# Only used on Win32
	target_sources(zsnes PRIVATE
		# macros.mac zpath.h jma/zsnesjma.h zip/zunzip.h argv.h cfg.h input.h
		mmlib/mm.h
		mmlib/mm.c
		mmlib/windows.c
		win/lib.c win/lib.h
		win/safelib.c
		win/winintrf.asm
		win/resource.h
		win/winlink.cpp
		win/zsnes.rc)
	zsnes_source_group(mmlib)
	zsnes_source_group(win)

	target_link_libraries(zsnes wsock32.lib user32.lib gdi32.lib shell32.lib winmm.lib)
	if (CMAKE_GENERATOR MATCHES "Visual Studio")
		if (CMAKE_VS_PLATFORM_TOOLSET STREQUAL "v100")
			# Assume Windows SDK 7.0a
			find_package(DirectX REQUIRED COMPONENTS dxguid)
			target_link_libraries(zsnes dinput8.lib DirectX::dxguid)
		elseif (CMAKE_VS_PLATFORM_TOOLSET STREQUAL "v90")
			# Assume Windows SDK 6.0a
			find_package(DirectX REQUIRED COMPONENTS dinput8 dsound dxguid)
			target_link_libraries(zsnes DirectX::dinput8 DirectX::dsound DirectX::dxguid)
		else()
			target_link_libraries(zsnes dinput8.lib dxguid.lib)
		endif()
	else()
		find_package(DirectX REQUIRED COMPONENTS dinput8 ddraw dsound dxguid)
		target_link_libraries(zsnes DirectX::dinput8 DirectX::ddraw DirectX::dsound DirectX::dxguid)
	endif()
	set_target_properties(zsnes PROPERTIES
		WIN32_EXECUTABLE ON
		OUTPUT_NAME "zsnesw")
elseif (CMAKE_SYSTEM_NAME STREQUAL "DOS")
	target_sources(zsnes PRIVATE
		# macros.mac
		dos/debug.asm
		dos/dosintrf.asm
		dos/gppro.asm
		dos/initvid.asm dos/vga.inc
		dos/joy.asm
		dos/lib.c dos/lib.h
		dos/sound.asm
		dos/sw.asm
		dos/vesa12.asm
		dos/vesa2.asm)
	zsnes_source_group(dos)
elseif (CMAKE_SYSTEM_NAME STREQUAL "Linux")
	find_package(OpenGL)

	target_sources(zsnes PRIVATE
		# asm_call.h cfg.h gblhdr.h argv.h input.h
		linux/audio.c linux/audio.h
		linux/battery.c
		linux/sdlintrf.asm
		linux/sdllink.c
		linux/gl_draw.h
		linux/sw_draw.c linux/sw_draw.h
		linux/safelib.c linux/safelib.h)
	zsnes_source_group(linux)
	if (OPENGL_FOUND)
		target_sources(zsnes PRIVATE linux/gl_draw.c)
		target_link_libraries(zsnes OpenGL::GL)
	endif()
endif()

zsnes_objfix(zsnes)

zsnes_target_defs_common(zsnes)
zsnes_target_platform_defs(zsnes)
zsnes_target_c_flags(zsnes)
zsnes_target_nasm_flags(zsnes)
