#!/bin/bash
# BYOToolchain (Ubuntu)
# Topher Lee
# 2019
# Based on: http://gnutoolchains.com/building/

echo -e "\e[41m==============================\e[0m"
echo -e "\e[41m|                            |\e[0m"
echo -e "\e[41m|  Build Your Own Toolchain  |\e[0m"
echo -e "\e[41m|                            |\e[0m"
echo -e "\e[41m==============================\e[0m"
echo ""

BASE_DIR=$(pwd)
SRC_DIR=$BASE_DIR/src
BUILD_DIR=$BASE_DIR/build
DOWNLOAD_DIR=$BASE_DIR/downloads

# TODO*: Set your own TARGET
# TODO 2: Enable Windows Compilers (Maybe a CMakeLists/Windows-only thing?)
# *
# $ TOOLCHAIN=powerpc-eabi || TOOLCHAIN=arm-eabi || TOOLCHAIN=x86_64
# $ ./BYOToolchain.sh
# * --- OR
# $ ./BYOToolchain.sh --arch=powerpc-eabi
# *
usage() {
  echo "  --> MORE OPTIONS PLANNED "
	echo "  --> Usage: ./build.sh [--help] [--clean]"
	echo "	1)   --help: print this message"
	echo "	2)   --clean: Clean environment (Delete 'build') folder..."
  echo "  --> MORE OPTIONS PLANNED "
	exit 0
}

while [[ $# -gt 0 ]]; do
	key="$1"

	case $key in
		--help)
			usage
			shift
			;;
      --clean)
  			###
  			### CLEANING ENVIRONMENT
  			###
        rm -rf $BUILD_DIR
  			#rm -rf $DOWNLOADS_DIR
  			if [ ! -d $DOWNLOADS_DIR ]; then
  				mkdir $DOWNLOADS_DIR
  			fi
        rm -rf $SRC_DIR
        #rm -rf $PREFIX
  			exit 1
  			;;
        --clang-only)
          #Placeholder for building Clang only
          shift
        ;;
  		*)
  			echo "Invalid argument: $key"
  			exit 1
  			;;
  	esac
  done
#if [$TARGET=null]
TARGET=arm-eabi
#fi
PREFIX=$BASE_DIR/prefix/$TARGET

echo "=============================="
echo ">"
echo "> - Building for "$TARGET
echo ">"
echo "=============================="
echo -e "\e[34;1m---> Downloading Sources\e[0m"
echo "=============================="
echo ""

#LOCAL VARIABLES

CONFIGURE_COMMAND="--target $TARGET --prefix $PREFIX"
ENABLE_WIN_BUILD="--enable-win32-registry=BYOToolchain/"$TARGET

#SOURCES (CAN BE EASILY UPDATED/DOWNGRADED)
BINUTILS_VERSION="2.32"
BINUTILS_FILE="binutils-"$BINUTILS_VERSION
BINUTILS_URL=http://ftp.gnu.org/gnu/binutils/$BINUTILS_FILE.tar.xz
BINUTILS_SRC_DIR=$SRC_DIR/binutils-src
BINUTILS_BUILD_DIR=$BUILD_DIR/binutils-build

GCC_VERSION="8.2.0"
GCC_FILE=gcc-$GCC_VERSION
GCC_URL=http://ftp.gnu.org/gnu/gcc/$GCC_FILE/"$GCC_FILE".tar.xz
GCC_SRC_DIR=$SRC_DIR/gcc-src
GCC_BUILD_DIR=$BUILD_DIR/gcc-build

NEWLIB_VERSION="3.1.0.20181231"
NEWLIB_FILE="newlib-"$NEWLIB_VERSION
NEWLIB_URL=ftp://sources.redhat.com/pub/newlib/$NEWLIB_FILE.tar.gz
NEWLIB_SRC_DIR=$SRC_DIR/newlib-src
NEWLIB_BUILD_DIR=$BUILD_DIR/newlib-build

GDB_VERSION="8.2.1"
GDB_FILE="gdb-"$GDB_VERSION
GDB_URL=ftp://sourceware.org/pub/gdb/releases/$GDB_FILE.tar.xz
GDB_SRC_DIR=$SRC_DIR/gdb-src
GDB_BUILD_DIR=$BUILD_DIR/gdb-build

LVVM_VERSION="7.0.1"
LVVM_FILE="llvm-"$LVVM_VERSION.src
CLANG_FILE="cfe-"$LVVM_VERSION.src
CLANG_TOOLS_FILE="clang-tools-extra-"$LVVM_VERSION.src
LVVM_URL=http://releases.llvm.org/$LVVM_VERSION/
LVVM_SRC_DIR=$SRC_DIR/lvvm-src
LVVM_BUILD_DIR=$BUILD_DIR/lvvm-build

echo "================"
echo "= Checking...  ="
echo "=  Downloads   ="
echo "================"
echo ""

if [ ! -d $DOWNLOAD_DIR ] ;then
    mkdir $DOWNLOAD_DIR
fi
cd $DOWNLOAD_DIR

### GCC DOWNLOAD
if [ ! -f $BINUTILS_FILE.tar.xz ] ;then
  echo "======================"
  echo -e "\e[31m---> Downloading BinUtils\e[0m"
  echo -e "\e[31m---> Version: \e[0m" $BINUTILS_VERSION
  echo "======================"
  echo ""
    wget $BINUTILS_URL
else
  echo "======================"
	echo -e "\e[32m---> BinUtils Already Downloaded\e[0m"
  echo "======================"
  echo ""
fi

if [ ! -f $GCC_FILE.tar.xz ] ;then
  echo "======================"
  echo -e "\e[31m---> Downloading GCC\e[0m"
  echo "======================"
  echo ""
  wget $GCC_URL
else
  echo "====================="
  echo -e "\e[32m---> GCC Already Downloaded\e[0m"
  echo "======================"
  echo ""
fi

if [ ! -f $NEWLIB_FILE.tar.gz ] ;then
  echo "====================="
  echo -e "\e[31m---> Downloading NewLib\e[0m"
  echo "======================"
  echo ""
    wget $NEWLIB_URL
  else
    echo "====================="
    echo -e "\e[32m---> NewLib Already Downloaded\e[0m"
    echo "======================"
    echo ""
  fi

if [ ! -f $GDB_FILE.tar.xz ] ;then
  echo "======================"
  echo -e "\e[31m---> Downloading GDB\e[0m"
  echo "======================"
  echo ""
  wget $GDB_URL
  else
  echo "====================="
  echo -e "\e[32m---> GDB Already Downloaded\e[0m"
  echo "======================"
  echo ""
fi

### CLANG DOWNLOAD
echo "======================"
echo -e "\e[31m---> Checking Clang \e[0m"
echo "======================"
echo ""
if [ ! -f $LVVM_FILE.tar.xz ] ;then
    wget $LVVM_URL/"$LVVM_FILE".tar.xz
fi

if [ ! -f $CLANG_FILE.tar.xz ] ;then
    wget $LVVM_URL/"$CLANG_FILE".tar.xz
fi

if [ ! -f $CLANG_TOOLS_FILE.tar.xz ] ;then
    wget $LVVM_URL/"$CLANG_TOOLS_FILE".tar.xz
fi

echo "================"
echo "= Extracting...="
echo "=   May Take   ="
echo "=   A While    ="
echo "================"
echo ""

if [ ! -d $SRC_DIR ] ;then
    mkdir $SRC_DIR
fi

cd $DOWNLOAD_DIR
# EXTRACT GCC AND EXTRAS
if [ ! -d $BINUTILS_FILE ] ;then
    tar -xf $BINUTILS_FILE.tar.xz
fi

if [ ! -d $BINUTILS_SRC_DIR ] ;then
  mkdir $BINUTILS_SRC_DIR
else
  mv "$BINUTILS_FILE"/* $BINUTILS_SRC_DIR
fi

if [ ! -d $GCC_FILE ] ;then
    tar -xf $GCC_FILE.tar.xz
fi

if [ ! -d $GCC_SRC_DIR ] ;then
  mkdir $GCC_SRC_DIR
else
  mv $GCC_FILE/* $GCC_SRC_DIR
fi

if [ ! -d $NEWLIB_FILE ] ;then
    tar -xf $NEWLIB_FILE.tar.gz
fi

if [ ! -d $NEWLIB_SRC_DIR ] ;then
  mkdir $NEWLIB_SRC_DIR
else
  mv $NEWLIB_FILE/* $NEWLIB_SRC_DIR
fi

if [ ! -d $GDB_FILE ] ;then
    tar -xf $GDB_FILE.tar.xz
fi

if [ ! -d $GDB_SRC_DIR ] ;then
  mkdir $GDB_SRC_DIR
else
  mv $GDB_FILE/* $GDB_SRC_DIR
fi
# EXTRACT CLANG
if [ ! -d $LVVM_FILE ] ;then
    tar -xf llvm-$LVVM_VERSION.tar.xz
fi

if [ ! -d $LVVM_SRC_DIR ] ;then
  mkdir $LVVM_SRC_DIR
  mv $LVVM_FILE/* $LVVM_SRC_DIR
fi
if [ ! -d $CLANG_FILE ] ;then
    tar -xf cfe-$LVVM_VERSION.tar.xz
fi

if [ -d $LVVM_SRC_DIR ] ;then
mv $CLANG_FILE/* $LVVM_SRC_DIR/tools/clang
fi

if [ ! -d $CLANG_TOOLS_FILE ] ;then
    tar -xf clang-tools-extra-$LVVM_VERSION.tar.xz
fi

if [ -d $LVVM_SRC_DIR ] ;then
mv $CLANG_TOOLS_FILE/* $LVVM_SRC_DIR/tools/clang/tools/extra
fi



echo "==============="
echo ">>> Building..."
echo "==============="
echo ""

if [ ! -d $BUILD_DIR ] ;then
  mkdir $BUILD_DIR
fi

cd $BUILD_DIR

if [ ! -d $BINUTILS_BUILD_DIR ] ;then
    mkdir $BINUTILS_BUILD_DIR
fi
cd $BINUTILS_BUILD_DIR
$BINUTILS_SRC_DIR/configure $CONFIGURE_COMMAND
make -j4
make install-strip

if [ ! -d $GCC_BUILD_DIR ] ;then
    mkdir $GCC_BUILD_DIR
fi
cd $GCC_BUILD_DIR
$GCC_SRC_DIR/configure $CONFIGURE_COMMAND --enable-languages=c,c++ --disable-nls --disable-shared --with-newlib --with-headers=$NEWLIB_SRC_DIR/newlib/libc/include
make -j4
make install-strip

if [ ! -d $NEWLIB_BUILD_DIR ] ;then
    mkdir $NEWLIB_BUILD_DIR
fi
cd $NEWLIB_BUILD_DIR
$NEWLIB_SRC_DIR/configure $CONFIGURE_COMMAND
make -j4
make install

if [ ! -d $GDB_BUILD_DIR ] ;then
    mkdir $GDB_BUILD_DIR
fi
cd $GDB_BUILD_DIR
$GDB_SRC_DIR/configure $CONFIGURE_COMMAND
make -j4
make install

if [ ! -d $LVVM_BUILD_DIR ] ;then
    mkdir $LVVM_BUILD_DIR
fi
cd $LVVM_BUILD_DIR
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_TARGET=$TARGET -G "Unix Makefiles" $LVVM_SRC_DIR
make
make install
cd $BASE_DIR
echo "============"
echo ">>> DONE..."
echo "============"
echo ""
