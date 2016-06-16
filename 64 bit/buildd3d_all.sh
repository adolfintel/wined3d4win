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
apt-get update -qq -y && apt-get dist-upgrade -qq -y && apt-get build-dep wine -qq -y && apt-get install mingw32 git -qq -y && apt-get autoremove -qq -y && apt-get clean -qq -y
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
rm -rf wine-tools wine-win64 wine-staging wine-git $p2 textureHack.patch
echo All done with no errors!
echo The wined3d dlls are in the wined3d and wined3d-staging directories
exit 0

#typeless texture hack from https://github.com/wine-mirror/wine/commit/77539c7716ca88599d7e0532e9e29328a85576f1
#edited to remove git stuff
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
M<F5S;W5R8V4I"B`@("`@>PH*+2TM(&1L;',O=VEN960S9"]R97-O=7)C92YC
M"BLK*R!D;&QS+W=I;F5D,V0O<F5S;W5R8V4N8PI`0"`M.#<L."`K.#<L."!`
M0$A215-53%0@<F5S;W5R8V5?:6YI="AS=')U8W0@=VEN960S9%]R97-O=7)C
M92`J<F5S;W5R8V4L('-T<G5C="!W:6YE9#-D7V1E=FEC92`J"B`@("`@("`@
M("`@("!R971U<FX@5TE.140S1$524E])3E9!3$E$0T%,3#L*("`@("`@("`@
M:68@*"AU<V%G92`F(%=)3D5$,T154T%'15]$15!42%-414Y#24PI("8F("$H
M9F]R;6%T+3YF;&%G<R`F("A724Y%1#-$1DU47T9,04=?1$505$@@?"!724Y%
M1#-$1DU47T9,04=?4U1%3D-)3"DI*0H@("`@("`@("`@("`@<F5T=7)N(%=)
M3D5$,T1%4E)?24Y604Q)1$-!3$P["BT@("`@("`@(&EF("@H=7-A9V4@)B!7
M24Y%1#-$55-!1T5?5$585%5212D@)B8@(2AF;W)M870M/F9L86=S("8@5TE.
M140S1$9-5%]&3$%'7U1%6%154D4I*0HM("`@("`@("`@("`@<F5T=7)N(%=)
M3D5$,T1%4E)?24Y604Q)1$-!3$P["BLO*B`@("`@("`@:68@*"AU<V%G92`F
M(%=)3D5$,T154T%'15]415A455)%*2`F)B`A*&9O<FUA="T^9FQA9W,@)B!7
M24Y%1#-$1DU47T9,04=?5$585%5212DI"BL@("`@("`@("`@("!R971U<FX@
M5TE.140S1$524E])3E9!3$E$0T%,3#LJ+PH@("`@('T*(`H@("`@(')E<V]U
M<F-E+3YR968@/2`Q.PI`0"`M,3$P+#<@*S$Q,"PV($!`2%)%4U5,5"!R97-O
M=7)C95]I;FET*'-T<G5C="!W:6YE9#-D7W)E<V]U<F-E("IR97-O=7)C92P@
M<W1R=6-T('=I;F5D,V1?9&5V:6-E("H*("`@("!R97-O=7)C92T^<&%R96YT
M(#T@<&%R96YT.PH@("`@(')E<V]U<F-E+3YP87)E;G1?;W!S(#T@<&%R96YT
M7V]P<SL*("`@("!R97-O=7)C92T^<F5S;W5R8V5?;W!S(#T@<F5S;W5R8V5?
M;W!S.PHM("`@(')E<V]U<F-E+3YM87!?8FEN9&EN9R`](%=)3D5$,T1?3$]#
M051)3TY?4UE3345-.PH@"B`@("`@:68@*'-I>F4I"B`@("`@>PH*+2TM(&1L
M;',O=VEN960S9"]S=7)F86-E+F,**RLK(&1L;',O=VEN960S9"]S=7)F86-E
M+F,*0$`@+3$X,3$L."`K,3@Q,2PQ,"!`0$A215-53%0@<W5R9F%C95]U<&QO
M861?9G)O;5]S=7)F86-E*'-T<G5C="!W:6YE9#-D7W-U<F9A8V4@*F1S=%]S
M=7)F86-E+"!C;VYS="!0"B`*("`@("`O*B!5<V4@=VEN960S9%]S=7)F86-E
M7V)L="@I(&EN<W1E860@;V8@=7!L;V%D:6YG(&1I<F5C=&QY(&EF('=E(&YE
M960@8V]N=F5R<VEO;BX@*B\*("`@("!D,V1F;71?9V5T7V-O;G8H9'-T7W-U
M<F9A8V4L($9!3%-%+"!44E5%+"`F9F]R;6%T+"`F8V]N=F5R="D["BT@("`@
M:68@*&-O;G9E<G0@(3T@5TE.140S1%]#5%].3TY%('Q\(&9O<FUA="YC;VYV
M97)T*0HK("`@(&EF("AC;VYV97)T("$](%=)3D5$,T1?0U1?3D].12!\?"!F
M;W)M870N8V]N=F5R="!\?"!F;W)M870N9VQ&;W)M870@/3T@,"D**R`@("![
M"B`@("`@("`@(')E='5R;B!W:6YE9#-D7W-U<F9A8V5?8FQT*&1S=%]S=7)F
M86-E+"`F9'-T7W)E8W0L('-R8U]S=7)F86-E+"!S<F-?<F5C="P@,"P@3E5,
M3"P@5TE.140S1%]415A&7U!/24Y4*3L**R`@("!]"B`*("`@("!C;VYT97AT
M(#T@8V]N=&5X=%]A8W%U:7)E*&1S=%]S=7)F86-E+3YR97-O=7)C92YD979I
M8V4L($Y53$PI.PH@("`@(&=L7VEN9F\@/2!C;VYT97AT+3YG;%]I;F9O.PI`
M0"`M,3@V,2PV("LQ.#8S+#$X($!`<W1A=&EC('9O:60@<W5R9F%C95]A;&QO
M8V%T95]S=7)F86-E*'-T<G5C="!W:6YE9#-D7W-U<F9A8V4@*G-U<F9A8V4L
M(&-O;G-T('-T<G4*("`@("!E;'-E"B`@("`@("`@(&EN=&5R;F%L(#T@9F]R
M;6%T+3YG;$EN=&5R;F%L.PH@"BL@("`@<W1R=6-T('=I;F5D,V1?9F]R;6%T
M("IF;W)M871?8VAE8VL@/2!F;W)M870["BL@("`@:68H(&9O<FUA="T^9VQ&
M;W)M870@/3T@,"D**R`@("!["BL@("`@("`@+RH@2&%N9&QE('1H92!T>7!E
M(&AE<F4L(&1E=&5R;6EN92!T:&ES(&1Y;F%M:6-A;&QY("HO"BL@("`@("`@
M:6YT97)N86P@/2!'3%]21T)!.#L**R`@("`@("!F;W)M871?8VAE8VLM/F=L
M1F]R;6%T(#T@1TQ?4D=".PHK("`@("`@(&9O<FUA=%]C:&5C:RT^9VQ4>7!E
M(#T@1TQ?54Y324=.141?0EE413L**R`@("`@("!44D%#12@B9'EN86UI8V%L
M;'D@9&5T97)M:6YI;F<@='EP92!B969O<F4@=7!L;V%D:6YG('1E>'1U<F4@
M=&\@8V%R9%QN(BD["BL**R`@("!]"BL**PH@("`@(&EF("@A:6YT97)N86PI
M"B`@("`@("`@($9)6$U%*").;R!'3"!I;G1E<FYA;"!F;W)M870@9F]R(&9O
M<FUA="`E<RY<;B(L(&1E8G5G7V0S9&9O<FUA="AF;W)M870M/FED*2D["B`*
M0$`@+30T,#@L-B`K-#0R,BPY($!`=F]I9"!S=7)F86-E7W9A;&ED871E7VQO
M8V%T:6]N*'-T<G5C="!W:6YE9#-D7W-U<F9A8V4@*G-U<F9A8V4L($173U)$
M(&QO8V%T:6]N*0H@=F]I9"!S=7)F86-E7VEN=F%L:61A=&5?;&]C871I;VXH
M<W1R=6-T('=I;F5D,V1?<W5R9F%C92`J<W5R9F%C92P@1%=/4D0@;&]C871I
M;VXI"B!["B`@("`@5%)!0T4H(G-U<F9A8V4@)7`L(&QO8V%T:6]N("5S+EQN
M(BP@<W5R9F%C92P@=VEN960S9%]D96)U9U]L;V-A=&EO;BAL;V-A=&EO;BDI
M.PHK("`@(&EF("AL;V-A=&EO;B`]/2`P>&9F9F9C,#`I"BL@("`@("`@;&]C
M871I;VX@/2`H5TE.140S1%],3T-!5$E/3E]415A455)%7U)'0B!\(%=)3D5$
M,T1?3$]#051)3TY?5$585%5215]34D="*3L**PH@"B`@("`@:68@*&QO8V%T
M:6]N("8@*%=)3D5$,T1?3$]#051)3TY?5$585%5215]21T(@?"!724Y%1#-$
M7TQ/0T%424].7U1%6%154D5?4U)'0BDI"B`@("`@("`@('=I;F5D,V1?=&5X
M='5R95]S971?9&ER='DH<W5R9F%C92T^8V]N=&%I;F5R*3L*0$`@+30X-S(L
M-B`K-#@X.2PX($!`2%)%4U5,5"!S=7)F86-E7VQO861?;&]C871I;VXH<W1R
M=6-T('=I;F5D,V1?<W5R9F%C92`J<W5R9F%C92P@1%=/4D0@;&]C871I;VXI
M"B`@("`@2%)%4U5,5"!H<CL*(`H@("`@(%1204-%*")S=7)F86-E("5P+"!L
M;V-A=&EO;B`E<RY<;B(L('-U<F9A8V4L('=I;F5D,V1?9&5B=6=?;&]C871I
M;VXH;&]C871I;VXI*3L**R`@("!I9B`H;&]C871I;VX@/3T@,'AF9F9F8S`P
M*0HK("`@("`@("!L;V-A=&EO;B`](#`["B`*("`@("!I9B`H<W5R9F%C92T^
M<F5S;W5R8V4N=7-A9V4@)B!724Y%1#-$55-!1T5?1$505$A35$5.0TE,*0H@
M("`@('L*0$`@+38Q-#8L-B`K-C$V-2PW($!`<W1A=&EC($A215-53%0@<W5R
M9F%C95]I;FET*'-T<G5C="!W:6YE9#-D7W-U<F9A8V4@*G-U<F9A8V4L('-T
M<G5C="!W:6YE9#-D7W1E>'0*("`@("!I9B`H;&]C:V%B;&4@?'P@9&5S8RT^
M9F]R;6%T(#T](%=)3D5$,T1&351?1#$V7TQ/0TM!0DQ%*0H@("`@("`@("!S
M=7)F86-E+3YR97-O=7)C92YA8V-E<W-?9FQA9W,@?#T@5TE.140S1%]215-/
M55)#15]!0T-%4U-?0U!5.PH@"BL@("`@<W5R9F%C92T^<F5S;W5R8V4N;6%P
M7V)I;F1I;F<@/2!724Y%1#-$7TQ/0T%424].7U-94TU%33L*("`@("!S=7)F
M86-E+3YT97AT=7)E7W1A<F=E="`]('1A<F=E=#L*("`@("!S=7)F86-E+3YT
M97AT=7)E7VQE=F5L(#T@;&5V96P["B`@("`@<W5R9F%C92T^=&5X='5R95]L
M87EE<B`](&QA>65R.PI`0"`M-C$X,RPW("LV,C`S+#$X($!`2%)%4U5,5"!W
M:6YE9#-D7W-U<F9A8V5?8W)E871E*'-T<G5C="!W:6YE9#-D7W1E>'1U<F4@
M*F-O;G1A:6YE<BP@8V]N<W0@<W1R=6-T('<*("`@("!S=')U8W0@=VEN960S
M9%]S=7)F86-E("IO8FIE8W0["B`@("`@=F]I9"`J<&%R96YT.PH@("`@($A2
M15-53%0@:'(["BT**R`@("!I;G0@9FEX<W5R9F%C92`](#`["BL@("`@:68H
M9&5S8RT^9F]R;6%T(#T](%=)3D5$,T1&351?4CA'.$(X03A?5%E014Q%4U,I
M"BL@("`@>PHK("`@("`@("!F:7AS=7)F86-E(#T@,3L**R`@("`@("`@*B@H
M:6YT("HI)BAD97-C+3YF;W)M870I*2`](%=)3D5$,T1&351?4CA'.$(X03A?
M54Y/4DT["BL@("`@("`@("HH*&EN="`J*28H9&5S8RT^=7-A9V4I*2`](#`[
M"BL@("`@?0HK("`@(&EF("AD97-C+3YU<V%G92`]/2`P>#$P,#`P,#`P*0HK
M("`@('L**R`@("`@("`@9FEX<W5R9F%C92`](#$["BL@("`@("`@("HH*&EN
M="`J*28H9&5S8RT^=7-A9V4I*2`](#`["BL@("`@?0H@("`@(%1204-%*")C
M;VYT86EN97(@)7`L('=I9'1H("5U+"!H96EG:'0@)74L(&9O<FUA="`E<RP@
M=7-A9V4@)7,@*"4C>"DL('!O;VP@)7,L("(*("`@("`@("`@("`@(")M=6QT
M:7-A;7!L95]T>7!E("4C>"P@;75L=&ES86UP;&5?<75A;&ET>2`E=2P@=&%R
M9V5T("4C>"P@;&5V96P@)74L(&QA>65R("5U+"!F;&%G<R`E(W@L('-U<F9A
M8V4@)7`N7&XB+`H@("`@("`@("`@("`@8V]N=&%I;F5R+"!D97-C+3YW:61T
M:"P@9&5S8RT^:&5I9VAT+"!D96)U9U]D,V1F;W)M870H9&5S8RT^9F]R;6%T
M*2P*0$`@+38R,3,L-B`K-C(T-"PX($!`2%)%4U5,5"!W:6YE9#-D7W-U<F9A
M8V5?8W)E871E*'-T<G5C="!W:6YE9#-D7W1E>'1U<F4@*F-O;G1A:6YE<BP@
M8V]N<W0@<W1R=6-T('<*("`@("!O8FIE8W0M/G)E<V]U<F-E+G!A<F5N="`]
M('!A<F5N=#L*("`@("!O8FIE8W0M/G)E<V]U<F-E+G!A<F5N=%]O<',@/2!P
M87)E;G1?;W!S.PH@("`@("IS=7)F86-E(#T@;V)J96-T.PHK("`@(&EF("AF
M:7AS=7)F86-E(#T](#$I"BL@("`@("`@("@J<W5R9F%C92DM/G)E<V]U<F-E
M+F%C8V5S<U]F;&%G<R!\/2!724Y%1#-$7U)%4T]54D-%7T%#0T534U]#4%4[
6"B`*("`@("!R971U<FX@:'(["B!]"@``
`
end
