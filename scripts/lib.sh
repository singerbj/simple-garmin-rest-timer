# Shared helpers for the dev scripts. Source this, don't run it.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

APP_NAME="RestTimer"
DEVICE="${DEVICE:-vivoactive4}"
KEY="${KEY:-$ROOT/developer_key.der}"
CIQ_HOME="$HOME/Library/Application Support/Garmin/ConnectIQ"

die() { echo "error: $*" >&2; exit 1; }
info() { echo "==> $*"; }

# Resolve the SDK: $CIQ_SDK, else the one selected in the SDK Manager.
find_sdk() {
    if [[ -n "${CIQ_SDK:-}" ]]; then
        echo "${CIQ_SDK%/}"
    elif [[ -f "$CIQ_HOME/current-sdk.cfg" ]]; then
        local sdk
        sdk="$(tr -d '\n' < "$CIQ_HOME/current-sdk.cfg")"
        echo "${sdk%/}"
    fi
}

# Homebrew's openjdk is keg-only, so put it on PATH ourselves when no system Java exists.
find_java() {
    if /usr/libexec/java_home >/dev/null 2>&1; then
        return 0
    fi
    local jdk
    for jdk in /opt/homebrew/opt/openjdk@17 /opt/homebrew/opt/openjdk /usr/local/opt/openjdk@17 /usr/local/opt/openjdk; do
        if [[ -x "$jdk/bin/java" ]]; then
            export PATH="$jdk/bin:$PATH"
            return 0
        fi
    done
    return 1
}

# Everything needed to run monkeyc / monkeydo.
require_toolchain() {
    find_java || die "Java not found. Run scripts/setup.sh."
    SDK="$(find_sdk)"
    [[ -n "$SDK" && -x "$SDK/bin/monkeyc" ]] \
        || die "Connect IQ SDK not found. Install it with the SDK Manager, or set CIQ_SDK."
    export PATH="$SDK/bin:$PATH"
    [[ -f "$KEY" ]] || die "Developer key $KEY not found. Run scripts/setup.sh."
}

require_device() {
    [[ -d "$CIQ_HOME/Devices/$1" ]] \
        || die "Device '$1' isn't downloaded. Add it in the SDK Manager."
}

prg_path() { echo "$ROOT/bin/$APP_NAME-$1.prg"; }
