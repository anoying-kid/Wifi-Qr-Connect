#!/usr/bin/env bash
set -euo pipefail

MASTER_PNG="./icon_master.png"
ICONSET_DIR="./Icon.iconset"

if [[ ! -f "$MASTER_PNG" ]]; then
    echo "ERROR: master PNG not found at $MASTER_PNG" >&2
    exit 1
fi

mkdir -p "$ICONSET_DIR"

# Resize images using sips (macOS built-in image processor)
sips -z 16 16     "$MASTER_PNG" --out "$ICONSET_DIR/icon_16x16.png" >/dev/null
sips -z 32 32     "$MASTER_PNG" --out "$ICONSET_DIR/icon_16x16@2x.png" >/dev/null
sips -z 32 32     "$MASTER_PNG" --out "$ICONSET_DIR/icon_32x32.png" >/dev/null
sips -z 64 64     "$MASTER_PNG" --out "$ICONSET_DIR/icon_32x32@2x.png" >/dev/null
sips -z 128 128   "$MASTER_PNG" --out "$ICONSET_DIR/icon_128x128.png" >/dev/null
sips -z 256 256   "$MASTER_PNG" --out "$ICONSET_DIR/icon_128x128@2x.png" >/dev/null
sips -z 256 256   "$MASTER_PNG" --out "$ICONSET_DIR/icon_256x256.png" >/dev/null
sips -z 512 512   "$MASTER_PNG" --out "$ICONSET_DIR/icon_256x256@2x.png" >/dev/null
sips -z 512 512   "$MASTER_PNG" --out "$ICONSET_DIR/icon_512x512.png" >/dev/null
sips -z 1024 1024 "$MASTER_PNG" --out "$ICONSET_DIR/icon_512x512@2x.png" >/dev/null

# Compile into Icon.icns
iconutil -c icns "$ICONSET_DIR"

# Clean up temporary directory
rm -rf "$ICONSET_DIR"
echo "Icon.icns successfully generated!"
