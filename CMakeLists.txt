cmake_minimum_required(VERSION 3.2.0)
# GNU Toolchain CMakeLists.txt
# Copy/Paste from OpenMW and OpenMW-Android CMakeLists.txt's
# https://github.com/OpenMW/openmw
# https://github.com/xyzz/openmw-android
# Add/Edit by Topher Lee

set(TOOLCHAIN_NAME BYOToolchain)
# http://ftp.gnu.org/gnu/binutils/binutils-2.31.1.tar.gz
set(BINUTILS_VERSION 2.31.1)
set(BINUTILS_HASH SHA256=e88f8d36bd0a75d3765a4ad088d819e35f8d7ac6288049780e2fefcad18dde88)
# http://ftp.gnu.org/gnu/gcc/gcc-8.2.0/gcc-8.2.0.tar.gz
set(GCC_VERSION 8.2.0)
set(GCC_HASH SHA256=1b0f36be1045ff58cbb9c83743835367b860810f17f0195a4e093458b372020f)
# ftp://sources.redhat.com/pub/newlib/newlib-3.1.0.20181231.tar.gz
set(NEWLIB_VERSION 3.1.0.20181231)
set(NEWLIB_HASH SHA256=9e12fea7297648b114434033ed4458755afe7b9b6c7d58123389e82bd37681c0)
# ftp://sourceware.org/pub/gdb/releases/gdb-8.2.1.tar.gz
set(GDB_VERSION 8.2.1)
set(GDB_HASH SHA256=0107985f1edb8dddef6cdd68a4f4e419f5fec0f488cc204f0b7d482c0c6c9282)
# End of configurable options

project(GNU-Toolchain)
include(ExternalProject)

set(prefix ${CMAKE_SOURCE_DIR}/prefix/)
set(download_dir ${CMAKE_SOURCE_DIR}/downloads/)

set(COMMON_CMAKE_ARGS
-DCMAKE_SHARED_LINKER_FLAGS=$ENV{LDFLAGS}
)

set(COMMON_AUTOCONF_FLAGS
#--build=${build}
--target=${target}
#--host=${host}
--prefix=${prefix}
)

set(GCC_AUTOCONF_FLAGS
${COMMON_AUTOCONF_FLAGS}
--enable-languages=c,c++
--disable-nls
--disable-shared
--with-newlib
)
set(GCC_CROSSCOMPILE_FLAGS
${GCC_AUTOCONF_FLAGS}
--with-headers=../newlib-${NEWLIB_VERSION}/newlib/libc/include
)
set(BINUTILS_INSTALL
install-strip
)

ExternalProject_Add(binutils
	URL http://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VERSION}.tar.gz
	URL_HASH ${BINUTILS_HASH}
	DOWNLOAD_DIR ${download_dir}

	CONFIGURE_COMMAND ${COMMON_CMAKE_ARGS} <SOURCE_DIR>/configure
	${COMMON_AUTOCONF_FLAGS}

	BUILD_COMMAND $(MAKE) check_PROGRAMS= bin_PROGRAMS=
	INSTALL_COMMAND $(MAKE) check_PROGRAMS= bin_PROGRAMS= ${BINUTILS_INSTALL}
)
ExternalProject_Add(newlib
	URL ftp://sources.redhat.com/pub/newlib/newlib-${NEWLIB_VERSION}.tar.gz
	URL_HASH ${NEWLIB_HASH}
	DOWNLOAD_DIR ${download_dir}

	CONFIGURE_COMMAND ${COMMON_CMAKE_ARGS} <SOURCE_DIR>/configure
	${COMMON_AUTOCONF_FLAGS}

	BUILD_COMMAND $(MAKE) check_PROGRAMS= bin_PROGRAMS=
	INSTALL_COMMAND $(MAKE) check_PROGRAMS= bin_PROGRAMS= install
)

ExternalProject_Add(gcc
	DEPENDS newlib

	URL http://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.gz
	URL_HASH ${GCC_HASH}
	DOWNLOAD_DIR ${download_dir}

	CONFIGURE_COMMAND ${COMMON_CMAKE_ARGS} <SOURCE_DIR>/configure
	${GCC_AUTOCONF_FLAGS}

	BUILD_COMMAND $(MAKE) check_PROGRAMS= bin_PROGRAMS=
	INSTALL_COMMAND $(MAKE) check_PROGRAMS= bin_PROGRAMS= ${BINUTILS_INSTALL}
)

ExternalProject_Add(gbd
	URL ftp://sourceware.org/pub/gdb/releases/gdb-${GDB_VERSION}.tar.gz
	URL_HASH ${GDB_HASH}
	DOWNLOAD_DIR ${download_dir}

	CONFIGURE_COMMAND ${COMMON_CMAKE_ARGS} <SOURCE_DIR>/configure
	${GCC_AUTOCONF_FLAGS}

	BUILD_COMMAND $(MAKE) check_PROGRAMS= bin_PROGRAMS=
	INSTALL_COMMAND $(MAKE) check_PROGRAMS= bin_PROGRAMS= ${BINUTILS_INSTALL}
)
