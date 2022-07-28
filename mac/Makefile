# This file is part of tdm-launcher.
# Copyright 2022 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE,
# Miniature Mobile Robots group, Switzerland
# Author: Yves Piguet

SRC = tdmlauncher.swift

tdmlauncher: $(SRC)
	swiftc -o $@ $^

# tdmlauncher.app: assume a complete (statically-linked) tdm is available
# in this directory as thymio-device-manager.
tdmlauncher.app: tdmlauncher thymio-device-manager Info.plist
	rm -Rf $@
	mkdir -p $@/Contents/MacOS
	cp Info.plist $@/Contents
	cp tdmlauncher $@/Contents/MacOS
	cp thymio-device-manager $@/Contents/MacOS
	mkdir -p $@/Contents/Resources
	cp org.mobsya.ThymioDeviceManager.icns $@/Contents/Resources
	mv $@ "ThymioDeviceManager.app"

