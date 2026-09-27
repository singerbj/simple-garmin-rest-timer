#!/usr/bin/env bash
# Build a release .iq for every device in the manifest, for the Connect IQ Store.
source "$(dirname "$0")/lib.sh"

require_toolchain

out="$ROOT/bin/$APP_NAME.iq"
mkdir -p "$ROOT/bin"
info "Packaging $out"
monkeyc -f monkey.jungle -e -r -o "$out" -y "$KEY" -w
