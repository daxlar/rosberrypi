#!/bin/bash
set -x

BUILD = "build-image"
SOURCES = "sources"
BUILD_DIR = "build_dir"
YOCTO_DISTRO = "dunfell"

mkdir ${BUILD}
pushd ${BUILD}

# setup the necessary sources in the build/sources directory
mkdir ${SOURCES}
pushd ${SOURCES}
git clone -b ${YOCTO_DISTRO} https://github.com/agherzan/meta-raspberrypi.git
git clone -b ${YOCTO_DISTRO} https://github.com/yoctoproject/poky.git
git clone -b ${YOCTO_DISTRO} https://github.com/openembedded/meta-openembedded.git
#git clone -b ${YOCTO_DISTRO} https://github.com/ros/meta-ros.git
#git clone -b ${YOCTO_DISTRO} https://github.com/yoctoproject/poky.git
popd 

# setup bblayers.conf and local.conf within the build/build_dir/conf directory
mkdir ${BUILD_DIR}
pushd ${BUILD_DIR}
# bblayers.conf 
echo BBLAYERS += \"..\${SOURCES}/sources/meta-raspberrypi\" >> conf/bblayers.conf || exit $?
echo BBLAYERS += \"..\${SOURCES}/sources/meta-openembedded/meta-oe\" >> conf/bblayers.conf || exit $?
echo BBLAYERS += \"..\${SOURCES}/sources/meta-openembedded/meta-multimedia\" >> conf/bblayers.conf || exit $?
echo BBLAYERS += \"..\${SOURCES}/sources/meta-openembedded/meta-networking\" >> conf/bblayers.conf || exit $?
echo BBLAYERS += \"..\${SOURCES}/sources/meta-openembedded/meta-python\" >> conf/bblayers.conf || exit $?
echo BBLAYERS += \"..\${SOURCES}/sources/poky/meta\" >> conf/bblayers.conf || exit $?
echo BBLAYERS += \"..\${SOURCES}/sources/poky/meta-poky\" >> conf/bblayers.conf || exit $?
echo BBLAYERS += \"..\${SOURCES}/sources/poky/meta-yocto-bsp\" >> conf/bblayers.conf || exit $?
echo BBPATH := \"${TOPDIR}\" >> conf/bblayers.conf || exit $?
echo BBFILES ?= "" >> conf/bblayers.conf || exit $?
# local.conf
echo "MACHINE ??= 'raspberrypi2'" >> conf/local.conf || exit $?
echo "BB_NUMBER_THREADS = \"11\"" >> conf/local.conf || exit $?
echo "PARALLEL_MAKE = \"-j 11 \"" >> conf/local.conf || exit $?
popd 

source ${SOURCES}/poky/oe-init-build-env ${BUILD_DIR}

bitbake core-image-base

