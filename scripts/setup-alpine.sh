#!/bin/sh
# Run as root INSIDE a dedicated Alpine 3.22 WSL distribution.
# Does not modify the Windows compiler environment.
set -eu
apk add clang llvm lld make python3 qemu-riscv64 musl-dev
mkdir -p /opt/riscv-apks /opt/riscv-sysroot
mirror=https://mirrors.tuna.tsinghua.edu.cn/alpine/v3.22/main/riscv64
for pkg in musl musl-dev; do
    wget "$mirror/$pkg-1.2.5-r12.apk" -O "/opt/riscv-apks/$pkg.apk"
    # APK signatures produce harmless tar extended-header warnings.
    tar -xzf "/opt/riscv-apks/$pkg.apk" -C /opt/riscv-sysroot
done
wget "$mirror/compiler-rt-20.1.8-r0.apk" -O /opt/riscv-apks/compiler-rt.apk
tar -xzf /opt/riscv-apks/compiler-rt.apk -C /opt/riscv-sysroot
test -f /opt/riscv-sysroot/usr/lib/libc.a
