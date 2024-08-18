echo "Run VM..."

qemu-system-x86_64 -cdrom $1 -m 2G -serial mon:stdio -enable-kvm
#qemu-system-x86_64 -cdrom $1 -m 2G -serial stdio -enable-kvm
