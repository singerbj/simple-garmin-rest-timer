#!/usr/bin/env bash
# Build a .prg for one device: scripts/build.sh [device]
source "$(dirname "$0")/lib.sh"

device="${1:-$DEVICE}"
require_toolchain
require_device "$device"

out="$(prg_path "$device")"
mkdir -p "$ROOT/bin"
info "Building $out"
monkeyc -f monkey.jungle -d "$device" -o "$out" -y "$KEY" -w
