#!/bin/bash
echo Checking system...
touch test_wined3d
if [ $? -ne 0 ]
then
	echo Cannot write in this directory
	exit 14
fi
rm -f test_wined3d
parallelism=$(grep -c ^processor /proc/cpuinfo)
echo Cleaning up...
unset CC
rm -rf wine-tools wine-win32 wine-git wine-staging
mkdir wine-tools wine-win32
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
../$p/configure --without-x
if [ $? -ne 0 ]
then
	echo Tools configure failed with error $?
	exit 3
fi
make -j$parallelism
if [ $? -ne 0 ]
then
	echo Tools make failed with error $?
	exit 4
fi
cd ../wine-win32
../$p/configure --without-x --disable-kernel32 --disable-tests --without-freetype --host=i686-w64-mingw32 CFLAGS="-O3 -DWINE_NOWINSOCK -DUSE_WIN32_OPENGL -DUSE_WIN32_VULKAN" --with-wine-tools=../wine-tools/ LDFLAGS=" -static-libgcc"
if [ $? -ne 0 ]
then
	echo Wine configure failed with error $?
	exit 5
fi
make -j$parallelism
if [ $? -ne 0 ]
then
	echo Wine make failed with error $?
	exit 6
fi
mkdir ../wined3d
cp dlls/wined3d/i386-windows/wined3d.dll dlls/ddraw/i386-windows/ddraw.dll dlls/d3d8/i386-windows/d3d8.dll dlls/d3d9/i386-windows/d3d9.dll dlls/d3d10/i386-windows/d3d10.dll dlls/d3d10core/i386-windows/d3d10core.dll dlls/d3d11/i386-windows/d3d11.dll dlls/dxgi/i386-windows/dxgi.dll dlls/d3d10_1/i386-windows/d3d10_1.dll ../wined3d
strip ../wined3d/*.dll
cd ..
rm -rf wine-tools/* wine-win32/*
echo Downloading wine-staging...
git clone https://github.com/wine-staging/wine-staging.git ./wine-staging
if [ $? -ne 0 ]
then
	echo Download failed with error $?
	exit 7
fi
echo Attempting to apply wine-staging...
cd wine-staging
rm -rf patches/*CSMT*
python ./staging/patchinstall.py --all -d "../$p2"
echo Applying additional patches...
cd ..
cd $p2
if [ -d ../patches ] && [ "$(ls ../patches)" ]; then
    for f in ../patches/*; do
        patch -p1 --forward < "$f"
    done
fi
echo Building...
cd ../wine-tools
../$p2/configure --without-x
if [ $? -ne 0 ]
then
	echo Tools configure failed with error $?
	exit 8
fi
make -j$parallelism
if [ $? -ne 0 ]
then
	echo Tools make failed with error $?
	exit 9
fi
cd ../wine-win32
../$p2/configure --without-x --disable-kernel32 --disable-tests --without-freetype --host=i686-w64-mingw32 CFLAGS="-O3 -DWINE_NOWINSOCK -DUSE_WIN32_OPENGL -DUSE_WIN32_VULKAN" --with-wine-tools=../wine-tools/ LDFLAGS=" -static-libgcc"
if [ $? -ne 0 ]
then
	echo Wine configure failed with error $?
	exit 10
fi
make -j$parallelism
if [ $? -ne 0 ]
then
	echo Wine make failed with error $?
	exit 11
fi
mkdir ../wined3d-staging
cp dlls/wined3d/i386-windows/wined3d.dll dlls/ddraw/i386-windows/ddraw.dll dlls/d3d8/i386-windows/d3d8.dll dlls/d3d9/i386-windows/d3d9.dll dlls/d3d10/i386-windows/d3d10.dll dlls/d3d10core/i386-windows/d3d10core.dll dlls/d3d11/i386-windows/d3d11.dll dlls/dxgi/i386-windows/dxgi.dll dlls/d3d10_1/i386-windows/d3d10_1.dll ../wined3d-staging
strip ../wined3d-staging/*.dll
cd ..
echo Cleaning up...
rm -rf wine-tools wine-win32 wine-staging wine-git $p2
echo All done with no errors!
echo The wined3d dlls are in the wined3d and wined3d-staging directories
exit 0


