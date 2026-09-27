#!/usr/bin/env bash
# Build and run in the simulator, starting it if needed: scripts/sim.sh [device]
source "$(dirname "$0")/lib.sh"

device="${1:-$DEVICE}"
"$ROOT/scripts/build.sh" "$device"
require_toolchain

if ! pgrep -f "ConnectIQ.app/Contents/MacOS/simulator" >/dev/null; then
    info "Starting simulator"
    connectiq
    sleep 3
fi

# The simulator takes a moment to accept connections after launch.
info "Running on $device"
for _ in 1 2 3 4 5 6 7 8 9 10; do
    if monkeydo "$(prg_path "$device")" "$device"; then
        exit 0
    fi
    sleep 2
done
die "Couldn't reach the simulator."
