#!/usr/bin/env bash
# Build and copy to a USB-connected watch: scripts/install.sh [device]
source "$(dirname "$0")/lib.sh"

device="${1:-$DEVICE}"
"$ROOT/scripts/build.sh" "$device"

prg="$(prg_path "$device")"
# Older watches mount as a drive; newer ones (like the vívoactive 4) use MTP.
apps="/Volumes/GARMIN/GARMIN/APPS"
if [[ -d "$apps" ]]; then
    cp "$prg" "$apps/$APP_NAME.prg"
    info "Copied to $apps/$APP_NAME.prg. Eject the watch to finish."
else
    cat <<EOF
No watch drive found at /Volumes/GARMIN.
Your watch probably uses MTP, which macOS doesn't mount. Open it in
OpenMTP (https://openmtp.ganeshrvel.com) and copy:
  $prg
into GARMIN/APPS/ on the watch.
EOF
    open -R "$prg"
fi
