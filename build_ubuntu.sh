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

function extract_linux_kernel () {
    echo "+ Extract Linux Kernel"
    if [ -f linux-6.10.3.tar.xz ] && [ ! -d linux-6.10.3 ]; then
        tar -xvf linux-6.10.3.tar.xz
    else 
        echo "Error: File Not Exist"
        exit -1
    fi
    echo "- Extract Linux Kernel"
}

function extract_ubuntu_base () {
    echo "+ Extract Ubuntu Base"
    if [ -f ubuntu-base-24.04-base-amd64.tar.gz ] && [ ! -d ubuntu-base ]; then
        mkdir ubuntu-base
        tar -xvzf ubuntu-base-24.04-base-amd64.tar.gz -C ubuntu-base
    else 
        echo "Error: File Not Exist"
        exit -1
    fi
    echo "- Extract Ubuntu Base"
}

echo "#########################"
echo "Simple Ubuntu Builder    "
echo "by Nakada Tokumei        "
echo "#########################"
echo ""

get_linux_kernel

get_ubuntu_base

extract_linux_kernel

extract_ubuntu_base
