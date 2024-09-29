#!/bin/bash

export is_android_kernel='n'

kernel_version=6.10.6
output_iso_file=simple-ubuntu.iso

repo_url=https://storage.googleapis.com/git-repo-downloads/repo
android_manifest_url=https://android.googlesource.com/kernel/manifest
android_manifest_branch=common-android15-6.6

function get_repo() {
    echo "+ Get Repo"
    if [ ! -d .bin/ ]; then
        mkdir .bin
    fi

    if [ ! -f .bin/repo ]; then
        curl ${repo_url} > .bin/repo
        chmod u+x .bin/repo
    fi
    echo "- Get Repo"
}

function get_linux_kernel () {
    echo "+ Get Linux Kernel"
    if [ ! -f linux-${kernel_version}.tar.xz ]; then
        wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${kernel_version}.tar.xz
    fi
    echo "- Get Linux Kernel"
}

function get_android_kernel() {
    echo "+ Get Android Kernel"

    if [ ! -d .repo/ ]; then
        ./.bin/repo init -u ${android_manifest_url} -b ${android_manifest_branch}
        ./.bin/repo sync
    fi

    echo "- Get Android Kernel"
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

function get_systemd() {
    echo "+ Get Systemd"
    if [ ! -f v256.4.zip ]; then
        wget https://github.com/systemd/systemd/archive/refs/tags/v256.4.zip
    fi
    echo "- Get Systemd"
}

function extract_linux_kernel () {
    echo "+ Extract Linux Kernel"
    if [ -f linux-${kernel_version}.tar.xz ] && [ ! -d linux-${kernel_version} ]; then
        tar -xvf linux-${kernel_version}.tar.xz
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

function extract_systemd () {
    echo "+ Extract Systemd"
    if [ -f v256.4.zip ] && [ ! -d systemd-256.4 ]; then
        unzip v256.4.zip
    fi
    echo "- Extract Systemd"
}

function config_linux_kernel_x86 () {
    echo "+ Config Linux Kernel for x86_64"
    if [ -d ./linux-${kernel_version} ]; then
        if [ ! -f ./linux-${kernel_version}/.config ]; then
            # cd ./linux-${kernel_version}
            # ARCH=x86 CROSS_COMPILE=x86_64-linux-gnu- make x86_64_defconfig
            # cd ../
            cp ./kernel_config/.config ./linux-${kernel_version}/
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

function build_android_kernel_x86 () {
    echo "+ Build Android Kerenl for x86_64"
    tools/bazel run //common:kernel_x86_64_dist -- --destdir=output_android/
    echo "- Build Android Kernel for x86_64"
}

function build_linux_kernel_x86 () {
    echo "+ Build Linux Kernel for x86_64"
    if [ -d ./linux-${kernel_version} ]; then
        cd ./linux-${kernel_version}
        ARCH=x86 CROSS_COMPILE=x86_64-linux-gnu- make -j$(nproc) bzImage
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

function build_systemd () {
    echo "+ Build Systemd"
    if [ -d ./systemd-256.4 ] && [ -d ./ubuntu-base ]; then
        cd ./systemd-256.4
        meson setup build/ && ninja -C build/
        DESTDIR=../../ubuntu-base meson install -C build/
        cd ../
    else
        echo "Systemd or Ubuntu base Folder not exist"
        exit -1
    fi
    echo "- Build Systemd"
}

function setup_init_script () {
    echo "+ Setup Init Script"
    if [ -d busybox-1_36_1/_install/ ]; then
        cp ./init_script/init busybox-1_36_1/_install/
    fi
    echo "- Setup Init Script"
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
    if [ ! -d output/boot/ ]; then
        mkdir -p output/boot
    fi
    cp ./busybox-1_36_1/initrd output/boot
    echo "- Set Initrd for Linux"
}

function set_grub_config() {
    echo "+ Set Grub configuration"
    if [ ! -d output/boot/grub ]; then
        mkdir -p output/boot/grub
    fi
    cp grub/grub.cfg output/boot/grub/
    echo "- Set Grub configuration"
}

function set_kernel_image() {
    echo "+ Set Kernel Image"
    if [ ! -d output/boot/ ]; then
        mkdir -p output/boot
    fi

    if [ $is_android_kernel == 'y' ]; then
        cp output_android/bzImage output/boot
    else
        cp linux-${kernel_version}/arch/x86/boot/bzImage output/boot
    fi

    echo "- Set Kernel Image"
}

function setup_tty_ubuntu_base() {
    echo "+ Setup tty1 for ubuntu base"
    if [ -d ./ubuntu-base ]; then
        cd ./ubuntu-base
        if [ ! -d etc/systemd/system/getty.target.wants ]; then
            mkdir -p etc/systemd/system/getty.target.wants
        fi
        ln -s /usr/lib/systemd/system/getty@.service etc/systemd/system/getty.target.wants/getty@tty1.service
        cd ../
    fi
    echo "- Setup tty1 for ubuntu base"
}

function make_squashfs() {
    echo "+ Make squshfs"

    which mksquashfs
    if [ $? -eq 0 ]; then
        mksquashfs ubuntu-base simple_ubuntu_live.squashfs
    else
        echo "mksqushfs not exist..."
        exit -1
    fi

    if [ ! -d output/live ]; then
        mkdir -p output/live
    fi

    mv simple_ubuntu_live.squashfs output/live

    echo "- Make squshfs"
}

function make_rescue_iso() {
    echo "+ Make rescue iso file"
    
    which grub-mkrescue
    if [ $? -eq 0 ]; then
        grub-mkrescue -o $output_iso_file output
    else
        echo "grub-mkrescue not exist..."
        exit -1
    fi
    echo "- Make resuce iso file"
}

function do_build() {

    if [ $is_android_kernel == 'y' ]; then
        get_repo
        get_android_kernel
    else
        get_linux_kernel
    fi

    get_ubuntu_base

    get_busybox

    get_systemd

    if [ $is_android_kernel != 'y' ]; then
        extract_linux_kernel
    fi

    extract_ubuntu_base

    extract_busybox

    extract_systemd

    if [ $is_android_kernel != 'y' ]; then
        config_linux_kernel_x86
    fi

    config_busybox_x86

    if [ $is_android_kernel == 'y' ]; then
        build_android_kernel_x86
    else
        build_linux_kernel_x86
    fi

    build_busybox_x86

    build_systemd

    setup_init_script

    setup_initrd

    set_initrd

    set_grub_config

    set_kernel_image

    setup_tty_ubuntu_base

    make_squashfs

    make_rescue_iso
}


echo "#########################"
echo "Simple Ubuntu Builder    "
echo "by Nakada Tokumei        "
echo "#########################"
echo ""

while [ $# -gt 0 ]; do
   case $1 in
        --android-kernel|--android)
            export is_android_kernel='y'
            echo "Hello"
            shift
            ;;
        *)
            shift
            ;;
   esac 
done

do_build
