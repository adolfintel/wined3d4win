# WineD3D For Windows Build Scripts
This repository contains the scripts I use to build [WineD3D For Windows](https://wined3d.fdossena.com).

## Download
You can get prebuilt DLL files from [my website](https://wined3d.fdossena.com)

__If you're trying to fix an old game, you _must use_ the 32 bit version, even on 64 bit systems.__

## Compatibility
These scripts were tested on Arch Linux and Debian. Older versions of this project supported Debian exclusively.

## How to build
### Prerequisites
To build WineD3D, you'll need to download some libraries first, most of them are probably already installed in your system. It is __strongly recommended__ to use a dedicated VM for building.

__Arch, Manjaro, etc.__ (Recommended)  
```bash
sudo pacman -Sy alsa-lib attr autoconf bison desktop-file-utils faudio ffmpeg flex fontconfig fontforge freetype2 gcc-libs gettext giflib git glu gnutls gsm gst-plugins-base-libs gtk3 lcms2 lib32-alsa-lib lib32-attr lib32-faudio lib32-fontconfig lib32-freetype2 lib32-gcc-libs lib32-gettext lib32-giflib lib32-glu lib32-gnutls lib32-gst-plugins-base-libs lib32-gtk3 lib32-lcms2 lib32-libcups lib32-libgl lib32-libldap lib32-libpcap lib32-libpng lib32-libpulse lib32-libsm lib32-libva lib32-libxcomposite lib32-libxcomposite lib32-libxcursor lib32-libxdamage lib32-libxi lib32-libxinerama lib32-libxml2 lib32-libxmu lib32-libxrandr lib32-libxslt lib32-libxxf86vm lib32-mesa lib32-mpg123 lib32-openal lib32-opencl-icd-loader lib32-sdl2 lib32-v4l-utils lib32-vkd3d lib32-vulkan-icd-loader libcups libgl libgphoto2 libldap libpcap libpng libpulse libsm libva libxcomposite libxcomposite libxcursor libxdamage libxi libxinerama libxml2 libxmu libxrandr libxslt libxxf86vm mesa mingw-w64-gcc mpg123 openal opencl-headers opencl-icd-loader perl samba sane sdl2 sharutils v4l-utils vkd3d vulkan-headers vulkan-icd-loader
```

__Debian, Ubuntu, etc.__  
Note: you need to use a 32 bit version of Debian to build the 32 bit DLLs and a 64 bit version for the 64 bit ones.

```bash
sudo apt build-dep wine
sudo apt install mingw-w64 git
```

### Building
__Latest version of WineD3D__  
```bash
sh build32.sh
```
The build process will take some time, at the end, you'll find 2 directories called wined3d and wined3d-staging, which will contain the build DLLs. The staging variant is built using [wine-staging](http://github.com/wine-compholio/wine-staging), which may improve compatibility.

__Specific version of WineD3D__  
If you want to build a specific version of WineD3D, all you have to do is download the tarball of the version you want to build, extract it, and run  
```bash
sh build32.sh path_to_source_code/
```
The build process will take some time, at the end, you'll find 2 directories called wined3d and wined3d-staging, which will contain the build DLLs. The staging variant is built using [wine-staging](http://github.com/wine-compholio/wine-staging), which may improve compatibility.

Note that this build may fail on very old versions of Wine.

### 64 bit build
The 64 bit version of WineD3D is only useful to run 64 bit apps on 64 bit Windows, it is __not for old games__.

To build 64 bit DLLs, simply replace `build32.sh` in the previous commands with `build64.sh`

## Special thanks
Thanks to Syvat G for improving the patched version to enhance compatibility!

## License
Copyright (C) 2014-2022 Federico Dossena

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
