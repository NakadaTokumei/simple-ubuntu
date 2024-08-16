#!/bin/bash

function get_linux_kernel () {
    echo "+ Get Linux Kernel"
    if [ ! -f linux-6.10.3.tar.xz ]; then
        wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.10.3.tar.xz
    fi
    echo "- Get Linux Kernel"
}

function get_ubuntu_base () {
    echo "+ Get Ubuntu Base"
    if [ ! -f ubuntu-base-24.04-base-amd64.tar.gz ]; then
        wget https://cdimage.ubuntu.com/ubuntu-base/releases/24.04/release/ubuntu-base-24.04-base-amd64.tar.gz
    fi
    echo "- Get Ubuntu Base"
}

function get_busybox() {
    echo "+ Get Busybox"
    if [ ! -f busybox-1_36_1.tar.bz2 ]; then
        wget https://git.busybox.net/busybox/snapshot/busybox-1_36_1.tar.bz2
    fi
    echo "- Get Busybox"
}

function extract_linux_kernel () {
    echo "+ Extract Linux Kernel"
    if [ -f linux-6.10.3.tar.xz ] && [ ! -d linux-6.10.3 ]; then
        tar -xvf linux-6.10.3.tar.xz
    fi
    echo "- Extract Linux Kernel"
}

function extract_ubuntu_base () {
    echo "+ Extract Ubuntu Base"
    if [ -f ubuntu-base-24.04-base-amd64.tar.gz ] && [ ! -d ubuntu-base ]; then
        mkdir ubuntu-base
        tar -xvzf ubuntu-base-24.04-base-amd64.tar.gz -C ubuntu-base
    fi
    echo "- Extract Ubuntu Base"
}

function extract_busybox () {
    echo "+ Extract Busybox"
    if [ -f busybox-1_36_1.tar.bz2 ] && [ ! -d busybox-1_36_1 ]; then
        tar -xvjf busybox-1_36_1.tar.bz2
    fi
    echo "- Extract Busybox"
}

function config_linux_kernel_x86 () {
    echo "+ Config Linux Kernel for x86_64"
    if [ -d ./linux-6.10.3 ]; then
        if [ ! -f ./linux-6.10.3/.config ]; then
            cd ./linux-6.10.3
            ARCH=x86 CROSS_COMPILE=x86_64-linux-gnu- make x86_64_defconfig
            cd ../
        fi
    else
        echo "Linux Kernel folder not exist"
    fi
    echo "- Config Linux Kernel for x86_64"
}

function config_busybox_x86 () {
    echo "+ Config Busybox for x86_64"
    if [ -d ./busybox-1_36_1 ] && [ ! -f ./busybox-1_36_1/.config ]; then
        cd ./busybox-1_36_1
        cp ../busybox_config/.config ./
        cd ..
    else
        echo "Busybox folder not exist"
    fi
    echo "- Config Busybox for x86_64"
}

function build_linux_kernel_x86 () {
    echo "+ Build Linux Kernel for x86_64"
    if [ -d ./linux-6.10.3 ]; then
        cd ./linux-6.10.3
        ARCH=x86 CROSS_COMPILE=x86_64-linux-gnu- make bzImage
        cd ../
    else
        echo "Linux Kernel folder not exist"
    fi
    echo "- Build Linux Kernel for x86_64"
}

function build_busybox_x86 () { 
    echo "+ Build Busybox for x86_64"
    if [ -d ./busybox-1_36_1 ]; then
        cd ./busybox-1_36_1
        ARCH=x86 CROSS_COMPILE=x86_64-linux-gnu- make
        ARCH=x86 CROSS_COMPILE=x86_64-linux-gnu- make install
        cd ../
    else
        echo "Busybox folder not exist"
    fi
    echo "- Build Busybox for x86_64"
}

function setup_initrd () {
    echo "+ Setup Initrd for Linux"
    if [ -d busybox-1_36_1/_install/ ]; then
        cd busybox-1_36_1/_install/
        find . | cpio -o --format=newc > ../initrd
        cd ../../
    fi
    echo "- Setup Initrd for Linux"
}

function set_initrd () {
    echo "+ Set Initrd for Linux"
    cp ./busybox-1_36_1/initrd ubuntu-base/boot
    echo "- Set Initrd for Linux"
}

function set_grub_config() {
    echo "+ Set Grub configuration"
    if [ ! -d ubuntu-base/boot/grub ]; then
        mkdir ubuntu-base/boot/grub
    fi
    cp grub/grub.cfg ubuntu-base/boot/grub/
    echo "- Set Grub configuration"
}

function set_kernel_image() {
    echo "+ Set Kernel Image"
    cp linux-6.10.3/arch/x86/boot/bzImage ubuntu-base/boot
    echo "- Set Kernel Image"
}

echo "#########################"
echo "Simple Ubuntu Builder    "
echo "by Nakada Tokumei        "
echo "#########################"
echo ""

get_linux_kernel

get_ubuntu_base

get_busybox

extract_linux_kernel

extract_ubuntu_base

extract_busybox

config_linux_kernel_x86

config_busybox_x86

build_linux_kernel_x86

build_busybox_x86

setup_initrd

set_initrd

set_grub_config

set_kernel_image