# simple-garmin-rest-timer

A tiny Connect IQ rest timer for the Garmin vívoactive 4 / 4S.

## Usage

- The screen shows the rest time (default **30**).
- **Top-right button**: start the countdown. Press again while it's running to reset.
- At **0** the watch vibrates, then resets to the set time.
- **Swipe up / down** (while stopped): change the time by ±1 s, from 1 to 180.
- The chosen time is saved and restored the next time the app opens.

## Build & install

1. Install the [Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/) and, in the SDK Manager, download the `vivoactive4` device.
2. Create a developer key once:
   ```sh
   openssl genrsa -out developer_key.pem 4096
   openssl pkcs8 -topk8 -inform PEM -outform DER -in developer_key.pem -out developer_key.der -nocrypt
   ```
3. Build:
   ```sh
   monkeyc -f monkey.jungle -d vivoactive4 -o bin/RestTimer.prg -y developer_key.der
   ```
4. Try it in the simulator (`connectiq`, then `monkeydo bin/RestTimer.prg vivoactive4`), or
   connect the watch over USB and copy `bin/RestTimer.prg` into `GARMIN/APPS/`.

The VS Code "Monkey C" extension can do steps 2–4 for you (`Monkey C: Build for Device`).
