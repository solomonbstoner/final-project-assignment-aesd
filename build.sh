#!/bin/bash
# Script to build image for qemu.
# Author: Siddhant Jajoo.

git submodule update --init --remote

function add_layer
{
	layer_name=$1
	if [ ! -d ../$layer_name ]; then
		echo "$layer_name directory does not exist"
		exit 1
	fi
	bitbake-layers show-layers | grep "$layer_name" > /dev/null
	layer_info=$?
	if [ $layer_info -ne 0 ];then
		echo "Adding $layer_name layer"
		bitbake-layers add-layer ../$layer_name
	else
		echo "$layer_name layer already exists in bitbake"
	fi
}

function add_conf
{
	CONFLINE=$1
	cat conf/local.conf | grep "${CONFLINE}" > /dev/null
	local_conf_info=$?
	if [ $local_conf_info -ne 0 ];then
		echo ${CONFLINE} >> conf/local.conf
		echo "Append ${CONFLINE} in the local.conf file"
	else
		echo "${CONFLINE} already exists in the local.conf file"
	fi
}

# local.conf won't exist until this step on first execution
source poky/oe-init-build-env

#CONFLINE="MACHINE = \"qemuarm64\""
add_conf "MACHINE = \"raspberrypi3-64\"" #https://meta-raspberrypi.readthedocs.io/en/latest/layer-contents.html#supported-machines
add_conf "LICENSE_FLAGS_ACCEPTED = \"synaptics-killswitch\"" # https://meta-raspberrypi.readthedocs.io/en/latest/ipcompliance.html#linux-firmware-rpidistro
add_conf "ENABLE_UART = \"1\"" # https://meta-raspberrypi.readthedocs.io/en/latest/ipcompliance.html#linux-firmware-rpidistro

add_layer "meta-raspberrypi"
add_layer "meta-openembedded/meta-oe" # Required for meta-python
add_layer "meta-openembedded/meta-python" # Required for meta-networking
add_layer "meta-openembedded/meta-networking" # Required for Wi-Fi
add_layer "meta-aesd"

set -e
bitbake core-image-aesd
