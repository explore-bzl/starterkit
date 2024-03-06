#!/bin/sh
set -e

# Check for build mode argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <build_mode>"
    echo "build_mode: i386, x86_64, mixed"
    exit 1
fi

BUILD_MODE=$1

UURL="http://downloads.yoctoproject.org/releases/uninative"
UVER="4.4"

UARCH32="i686"
UARCH64="x86_64"
USUFFIX="nativesdk-libc.tar.xz"

# Create necessary directories
mkdir -p /lib /lib64 /usr/lib

# Function to process architecture
process_arch() {
    UARCH=$1
    USYSROOT="${UARCH}-${USUFFIX}"

    # Exclude audit and .debug directories during extraction
    wget -q -O - "${UURL}/${UVER}/${USYSROOT}" | tar -xJ
    rm -fr "${UARCH}-linux/lib/.debug"
    rm -fr "${UARCH}-linux/usr/lib/audit"
    mv "${UARCH}-linux/lib" "/lib/${UARCH}-linux-gnu"
    echo "/lib/${UARCH}-linux-gnu" >> /etc/ld.so.conf

    mv "${UARCH}-linux/usr/lib" "/usr/lib/${UARCH}-linux-gnu"
    echo "/usr/lib/${UARCH}-linux-gnu" >> /etc/ld.so.conf

    mkdir -p "/usr/local/oe-sdk-hardcoded-buildpath/sysroots/${UARCH}-pokysdk-linux/etc"
    ln -sf /etc/ld.so.cache "/usr/local/oe-sdk-hardcoded-buildpath/sysroots/${UARCH}-pokysdk-linux/etc/ld.so.cache"

    # Create ld-linux symlink based on architecture
    if [ "$UARCH" = "i686" ]; then
        ln -s /lib/i686-linux-gnu/ld-linux.so.2 /lib/ld-linux.so.2
    elif [ "$UARCH" = "x86_64" ]; then
        ln -s /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2
    fi
}

# Process architectures based on build mode
case $BUILD_MODE in
    i386)
        process_arch $UARCH32
        ;;
    x86_64)
        process_arch $UARCH64
        ;;
    mixed)
        process_arch $UARCH32
        process_arch $UARCH64
        ;;
    *)
        echo "Invalid build mode: $BUILD_MODE"
        exit 1
        ;;
esac

/ldconfig -f /etc/ld.so.conf -C /etc/ld.so.cache

echo 'root:x:0:0:root:/:/bin/sh' > /etc/passwd
