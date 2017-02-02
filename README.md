# WineD3D For Windows Build Scripts
This repository contains the scripts I use to build [WineD3D For Windows](http://wined3d.fdossena.com).

## Download
You can get prebuilt DLL files from [my website](http://wined3d.fdossena.com)

__If you're trying to fix an old game, you _must use_ the 32 bit version, even on 64 bit systems.__

## Compatibility
These scripts currently require Debian GNU/Linux. Specifically, you'll need the 32 bit version to build the 32 bit DLLs, and a 64 bit version to build the 64 bit DLLs.
 
## Usage
__An Internet connection is required in order to download the required dependencies and source code.__

#### Build latest version of WineD3D
```bash
sh buildd3d_all.sh
```
The build process will take some time, at the end, you'll find 2 directories called wined3d and wined3d-staging, which will contain the build DLLs. The staging variant is built using [wine-staging](http://github.com/wine-compholio/wine-staging), which may improve compatibility.

#### Build a specific version of WineD3D
As far as I know, cross-compiling WineD3D with this method only works since __version 1.6__. The patched version will most likely fail to build unless you're using the latest version of Wine.

All you have to do is download the tarball of the version you want to build, extract it, and run
```bash
sh buildd3d_all.sh path_to_extracted_files/
```
The build process will take some time, at the end, you'll find 2 directories called wined3d and wined3d-staging, which will contain the build DLLs. The staging variant is built using [wine-staging](http://github.com/wine-compholio/wine-staging), which may improve compatibility.

## Special thanks ##
Thanks to Syvat G for improving the patched version to enhance compatibility!

## Your code is shit!
Feel free to improve it and send a pull request.

## License
Copyright (C) 2016 Federico Dossena

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