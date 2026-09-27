#!/usr/bin/env bash
# One-time setup: installs Java if needed, creates the developer key, and checks the SDK.
source "$(dirname "$0")/lib.sh"

if find_java; then
    info "Java: $(java -version 2>&1 | head -1)"
else
    command -v brew >/dev/null || die "Java not found and Homebrew isn't installed. Install a JDK (17+) manually."
    info "Installing Java (openjdk@17) with Homebrew"
    brew install openjdk@17
    find_java || die "Java still not found after install."
fi

SDK="$(find_sdk)"
if [[ -n "$SDK" && -x "$SDK/bin/monkeyc" ]]; then
    info "SDK: $SDK"
else
    die "Connect IQ SDK not found. Install it from https://developer.garmin.com/connect-iq/sdk/ and download an SDK in the SDK Manager."
fi

if [[ -f "$KEY" ]]; then
    info "Developer key: $KEY"
else
    info "Creating developer key"
    openssl genrsa -out "${KEY%.der}.pem" 4096
    openssl pkcs8 -topk8 -inform PEM -outform DER -in "${KEY%.der}.pem" -out "$KEY" -nocrypt
fi

if [[ -d "$CIQ_HOME/Devices/$DEVICE" ]]; then
    info "Device: $DEVICE"
else
    echo "warning: device '$DEVICE' isn't downloaded yet. Add it in the SDK Manager." >&2
fi

info "Ready. Try: scripts/sim.sh"
