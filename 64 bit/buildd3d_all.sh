#!/bin/bash
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as superuser"
   exit 15
fi
echo Checking system...
if [ ! -f /etc/debian_version ]
then
	echo This script requires a Debian system
	exit 12
fi
case $(uname -m) in
x86_64)
    x64=1
    ;;
amd64)
	x64=1
	;;
*)
    x64=0
    ;;
esac
if [ $x64 -ne 1 ]
then
	echo "This script requries an x86_64 system (x86_64, amd64)"
	exit 13
fi

touch test_wined3d
if [ $? -ne 0 ]
then
	echo Cannot write in this directory
	exit 14
fi
rm -f test_wined3d
echo Downloading system updates and required dependencies...
apt-get update -qq -y && apt-get upgrade -qq -y && apt-get dist-upgrade -qq -y && apt-get build-dep wine -qq -y && apt-get install mingw-w64 git -qq -y && apt-get clean -qq -y
if [ $? -ne 0 ]
then
	echo Download failed with error $?
	exit 1
fi
echo Cleaning up...
unset CC
rm -rf wine-tools wine-win64 wine-git wine-staging
mkdir wine-tools wine-win64
if [ -z ${1} ] 
then
	echo Downloading wine...
	git clone git://source.winehq.org/git/wine.git ./wine-git
	if [ $? -ne 0 ]
	then
		echo Download failed with error $?
		exit 2
	fi
	p="wine-git/"
else
	echo Building from $1
	p=$1
fi
p2=$(realpath --relative-to=. $p)"-copy/"
mkdir $p2
rm -rf $p2"/"*
cp -rf $p"/"* $p2
echo Building...
unset CC
cd wine-tools
../$p/configure --without-x --enable-win64
if [ $? -ne 0 ]
then
	echo Tools configure failed with error $?
	exit 3
fi
make __tooldeps__
if [ $? -ne 0 ]
then
	echo Tools make failed with error $?
	exit 4
fi
cd ../wine-win64
../$p/configure --without-x --enable-win64 --without-freetype --host=x86_64-w64-mingw32 CFLAGS="-O2 -DWINE_NOWINSOCK -DUSE_WIN32_OPENGL" --with-wine-tools=../wine-tools/ LDFLAGS=" -static-libgcc"
if [ $? -ne 0 ]
then
	echo Wine configure failed with error $?
	exit 5
fi
make dlls/wined3d dlls/ddraw dlls/d3d8 dlls/d3d9 dlls/d3d10 dlls/d3d10core dlls/d3d11 dlls/dxgi dlls/d3d10_1
if [ $? -ne 0 ]
then
	echo Wine make failed with error $?
	exit 6
fi
mkdir ../wined3d
cp libs/wine/libwine.dll dlls/wined3d/wined3d.dll dlls/ddraw/ddraw.dll dlls/d3d8/d3d8.dll dlls/d3d9/d3d9.dll dlls/d3d10/d3d10.dll dlls/d3d10core/d3d10core.dll dlls/d3d11/d3d11.dll dlls/dxgi/dxgi.dll dlls/d3d10_1/d3d10_1.dll ../wined3d
cd ..
echo Downloading wine-staging...
git clone https://github.com/wine-compholio/wine-staging.git ./wine-staging
if [ $? -ne 0 ]
then
	echo Download failed with error $?
	exit 7
fi
echo Applying wine-staging
rm -rf wine-tools/* wine-win64/*
cd wine-staging
./patches/patchinstall.sh DESTDIR="../$p2/" --all
echo Building...
cd ../wine-tools
../$p2/configure --without-x --enable-win64
if [ $? -ne 0 ]
then
	echo Tools configure failed with error $?
	exit 8
fi
make __tooldeps__
if [ $? -ne 0 ]
then
	echo Tools make failed with error $?
	exit 9
fi
cd ../wine-win64
../$p2/configure --without-x --enable-win64 --without-freetype --host=x86_64-w64-mingw32 CFLAGS="-O2 -DWINE_NOWINSOCK -DUSE_WIN32_OPENGL" --with-wine-tools=../wine-tools/ LDFLAGS=" -static-libgcc"
if [ $? -ne 0 ]
then
	echo Wine configure failed with error $?
	exit 10
fi
make dlls/wined3d dlls/ddraw dlls/d3d8 dlls/d3d9 dlls/d3d10 dlls/d3d10core dlls/d3d11 dlls/dxgi dlls/d3d10_1
if [ $? -ne 0 ]
then
	echo Wine make failed with error $?
	exit 11
fi
mkdir ../wined3d-staging
cp libs/wine/libwine.dll dlls/wined3d/wined3d.dll dlls/ddraw/ddraw.dll dlls/d3d8/d3d8.dll dlls/d3d9/d3d9.dll dlls/d3d10/d3d10.dll dlls/d3d10core/d3d10core.dll dlls/d3d11/d3d11.dll dlls/dxgi/dxgi.dll dlls/d3d10_1/d3d10_1.dll ../wined3d-staging
cd ..
echo Cleaning up...
rm -rf wine-tools wine-win64 wine-staging wine-git $p2
echo All done with no errors!
echo The wined3d dlls are in the wined3d and wined3d-staging directories
exit 0
