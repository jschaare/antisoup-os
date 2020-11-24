#!/bin/bash

set -e

if [[ $EUID -eq 0 ]]; then
    echo "Do not run this as the root user, exiting..."
    exit 1
fi

if command -v docker > /dev/null; then
    echo "Docker found..."
else
    echo "Docker not found, exiting..."
    exit 1
fi

if [ "$(uname -m)" = "aarch64" ]; then
    BUILD_TOOLS="aarch64-buildtools-extended-nativesdk-standalone-3.1.3.sh"
elif [ "$(uname -m)" = "x86_64" ]; then
    BUILD_TOOLS="x86_64-buildtools-extended-nativesdk-standalone-3.1.3.sh"
else
    echo "Unsupported arch, exiting..."
    exit 1
fi

echo "Downloading build tools..."

pushd sources > /dev/null
wget -nc https://downloads.yoctoproject.org/releases/yocto/yocto-3.1.3/buildtools/${BUILD_TOOLS}
popd > /dev/null

echo "Building Docker image..."

docker build --build-arg "host_uid=$(id -u)" --build-arg "host_gid=$(id -g)" \
    --tag "antisoup-os-image:latest" .

echo "Running Docker image and starting yocto build..."
docker run -it --rm \
    -e BUILD_TOOLS_SCR=$BUILD_TOOLS \
    -v $PWD/sources:/home/antisoup/yocto/src \
    -v $PWD/output:/home/antisoup/yocto/out \
    antisoup-os-image:latest
