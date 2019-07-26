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
i*86)
    x86=1
    ;;
*)
    x86=0
    ;;
esac
if [ $x86 -ne 1 ]
then
	echo "This script requries an x86 system (i386, i486, i586, i686)"
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
apt-get update -qq -y && apt-get dist-upgrade -qq -y && apt-get build-dep wine -qq -y && apt-get install mingw-w64 git -qq -y && apt-get autoremove -qq -y && apt-get clean -qq -y
if [ $? -ne 0 ]
then
	echo Download failed with error $?
	exit 1
fi
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
make __tooldeps__
if [ $? -ne 0 ]
then
	echo Tools make failed with error $?
	exit 4
fi
cd ../wine-win32
../$p/configure --without-x --without-freetype --host=i686-w64-mingw32 CFLAGS="-O2 -DWINE_NOWINSOCK -DUSE_WIN32_OPENGL -DUSE_WIN32_VULKAN" --with-wine-tools=../wine-tools/ LDFLAGS=" -static-libgcc"
if [ $? -ne 0 ]
then
	echo Wine configure failed with error $?
	exit 5
fi
make libs/port
make dlls/wined3d dlls/ddraw dlls/d3d8 dlls/d3d9 dlls/d3d10 dlls/d3d10core dlls/d3d11 dlls/dxgi dlls/d3d10_1
if [ $? -ne 0 ]
then
	echo Wine make failed with error $?
	exit 6
fi
mkdir ../wined3d
cp dlls/wined3d/wined3d.dll dlls/ddraw/ddraw.dll dlls/d3d8/d3d8.dll dlls/d3d9/d3d9.dll dlls/d3d10/d3d10.dll dlls/d3d10core/d3d10core.dll dlls/d3d11/d3d11.dll dlls/dxgi/dxgi.dll dlls/d3d10_1/d3d10_1.dll ../wined3d
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
sed 's/exit 1//g' patches/patchinstall.sh > patches/patchinstall1.sh
chmod 775 patches/patchinstall1.sh
./patches/patchinstall1.sh DESTDIR="../$p2/" --all
echo Attempting Typeless Texture Hack...
cd ..
uudecode ${0}
cd $p2
patch -p0 < ../textureHack.patch
echo Building...
cd ../wine-tools
../$p2/configure --without-x
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
cd ../wine-win32
../$p2/configure --without-x --without-freetype --host=i686-w64-mingw32 CFLAGS="-O2 -DWINE_NOWINSOCK -DUSE_WIN32_OPENGL -DUSE_WIN32_VULKAN" --with-wine-tools=../wine-tools/ LDFLAGS=" -static-libgcc"
if [ $? -ne 0 ]
then
	echo Wine configure failed with error $?
	exit 10
fi
make libs/port
make dlls/wined3d dlls/ddraw dlls/d3d8 dlls/d3d9 dlls/d3d10 dlls/d3d10core dlls/d3d11 dlls/dxgi dlls/d3d10_1
if [ $? -ne 0 ]
then
	echo Wine make failed with error $?
	exit 11
fi
mkdir ../wined3d-staging
cp dlls/wined3d/wined3d.dll dlls/ddraw/ddraw.dll dlls/d3d8/d3d8.dll dlls/d3d9/d3d9.dll dlls/d3d10/d3d10.dll dlls/d3d10core/d3d10core.dll dlls/d3d11/d3d11.dll dlls/dxgi/dxgi.dll dlls/d3d10_1/d3d10_1.dll ../wined3d-staging
cd ..
echo Cleaning up...
rm -rf wine-tools wine-win32 wine-staging wine-git $p2
rm textureHack.patch
echo All done with no errors!
echo The wined3d dlls are in the wined3d and wined3d-staging directories
exit 0

#typeless texture hack from https://github.com/wine-mirror/wine/commit/77539c7716ca88599d7e0532e9e29328a85576f1
#edited to remove git stuff and unnecessary changes
begin 755 textureHack.patch
M+2TM(&1L;',O=VEN960S9"]D979I8V4N8PHK*RL@9&QL<R]W:6YE9#-D+V1E
M=FEC92YC"D!`("TS-C<V+#8@*S,V-S8L,3$@0$!V;VED($-$14-,('=I;F5D
M,V1?9&5V:6-E7V-O<'E?<F5S;W5R8V4H<W1R=6-T('=I;F5D,V1?9&5V:6-E
M("ID979I8V4L"B`@("`@2%)%4U5,5"!H<CL*(`H@("`@(%1204-%*")D979I
M8V4@)7`L(&1S=%]R97-O=7)C92`E<"P@<W)C7W)E<V]U<F-E("5P+EQN(BP@
M9&5V:6-E+"!D<W1?<F5S;W5R8V4L('-R8U]R97-O=7)C92D["BL@("`@:68@
M*&1S=%]R97-O=7)C92T^9F]R;6%T+3YI9"`]/2!724Y%1#-$1DU47U(X1SA"
M.$$X7U194$5,15-3*0HK("`@('L**R`@("`@("`J*"AI;G0@*BDF*&1S=%]R
M97-O=7)C92T^9F]R;6%T+3YI9"DI(#T@<W)C7W)E<V]U<F-E+3YF;W)M870M
M/FED.PHK("`@('T**PH@"B`@("`@:68@*'-R8U]R97-O=7)C92`]/2!D<W1?
3<F5S;W5R8V4I"B`@("`@>PH*"@``
`
end

