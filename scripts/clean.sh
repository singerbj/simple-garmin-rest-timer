#!/usr/bin/env bash
# Remove build output.
source "$(dirname "$0")/lib.sh"

rm -rf "$ROOT/bin"
info "Removed bin/"
