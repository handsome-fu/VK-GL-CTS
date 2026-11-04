#!/bin/bash

set -eo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
RELDIR="$(pwd)/dir_to_deploy"

echo "RELDIR:$RELDIR"

#-------------------------------------------------------------------------------
# configure
#-------------------------------------------------------------------------------

. /opt/fsl-imx-internal-xwayland/6.18-wrynose/environment-setup-armv8-2a-poky-linux


export http_proxy=http://apac.nics.nxp.com:8080
export https_proxy=http://apac.nics.nxp.com:8080

python external/fetch_sources.py

mkdir -p build
cd build
cmake .. \
     -G Ninja \
     -DDEQP_TARGET=wayland \
     -DCMAKE_BUILD_TYPE=Debug \
     -DSELECTED_BUILD_TARGETS="deqp-vk deqp-gles2 deqp-gles3 deqp-gles31 deqp-egl cts-runner glcts"

#-------------------------------------------------------------------------------
# Build and copy
#-------------------------------------------------------------------------------
ninja

# CTS has no install rules for these executables or their runtime resources.
install -d "$RELDIR"
install -m 755 \
     modules/egl/deqp-egl \
     modules/gles2/deqp-gles2 \
     modules/gles3/deqp-gles3 \
     modules/gles31/deqp-gles31 \
     external/vulkancts/modules/vulkan/deqp-vk \
     external/openglcts/modules/cts-runner \
     external/openglcts/modules/glcts \
     "$RELDIR/"

# The programs share resources relative to the working directory.
cp -a external/openglcts/modules/{gl_cts,gles2,gles3,gles31} "$RELDIR/"
cp -a external/vulkancts/modules/vulkan/vulkan \
     external/vulkancts/modules/vulkan/vk-*/ "$RELDIR/"
cp -a ../external/vulkancts/mustpass/main/vk-default.txt \
     ../android/cts/main/vk-*.txt "$RELDIR/"

echo "Done: $RELDIR"
echo "Run the tests from this directory so they can find their resources."
