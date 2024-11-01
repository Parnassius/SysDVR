#!/bin/sh

set -e

# install flatpak dependencies
flatpak install --user -y flathub org.freedesktop.Platform//22.08 org.freedesktop.Sdk//22.08 runtime/org.freedesktop.Sdk.Extension.dotnet6/x86_64/22.08

if [ ! -d "shared-modules" ]; then
	mkdir shared-modules
	cd shared-modules
	git init
	git remote add origin https://github.com/flathub/shared-modules.git
	git fetch --depth 1 origin d88a9156b91eef64ecf1a313c868f1401c4bb39b
	git checkout FETCH_HEAD
	cd ..
fi

cd .. # Go to Platforms folder

echo Checking dependencies...

mkdir -p Resources/linux-x64/native

# cimgui_rX is the git tag for for the release we are usign of cimgui
if [ ! -e "Resources/linux-x64/native/cimgui_r2" ]; then
	echo Downloading Cimgui...
	curl -L https://github.com/exelix11/CimguiSDL2Cross/releases/download/r2/linux-x64.zip -o linux-x64.zip
	unzip linux-x64.zip
	mv cimgui.so Resources/linux-x64/native/cimgui.so
	echo ok > "Resources/linux-x64/native/cimgui_r2"
fi

cd .. # Go to client root
dotnet publish -c Release -r linux-x64
cd Platform/Linux

if [ -d "dvr-build" ]; then
	rm -rf dvr-build
fi

mkdir -p dvr-build
cp -r ../../bin/Release/net8.0/linux-x64/publish/* dvr-build/

flatpak-builder --user --install tmp com.github.exelix11.sysdvr.json --force-clean
flatpak build-bundle ~/.local/share/flatpak/repo SysDVR-Client.flatpak com.github.exelix11.sysdvr --runtime-repo=https://flathub.org/repo/flathub.flatpakrepo
