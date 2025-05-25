# See https://git.yoctoproject.org/poky/tree/meta/files/common-licenses
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

# TODO: Set this  with the path to your assignments rep.  Use ssh protocol and see lecture notes
# about how to setup ssh-agent for passwordless access
SRC_URI = "git://git@github.com/cu-ecen-aeld/assignments-3-and-later-solomonbstoner.git;protocol=ssh;branch=ass-9"
PV = "1.0+git${SRCPV}"
SRCREV = "b4857fd69e4b43d55d62946886e9739c6afacc3d"

SUMMARY = "Example of how to build an external Linux kernel module"
DESCRIPTION = "${SUMMARY}"

# Patch the Makefile to make it Yocto compatible
FILESEXTRAPATHS:prepend := "${THISDIR}/patches:"
SRC_URI += "file://01-makefile.patch"

inherit module

S = "${WORKDIR}/git/aesd-char-driver"
UNPACKDIR = "${S}"

# Add to FILES because of installed-vs-shipped
FILES:${PN} += "${bindir}/aesdchar_load ${bindir}/aesdchar_unload"
# Files necessary to load and unload the driver
do_install:append() {
    install -d ${D}${bindir}
    install -m 0755 aesdchar_load ${D}${bindir}
    install -m 0755 aesdchar_unload ${D}${bindir}
}

# The inherit of module.bbclass will automatically name module packages with
# "kernel-module-" prefix as required by the oe-core build environment.
RPROVIDES:${PN} += "kernel-module-aesd-char-driver"
