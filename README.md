# CaffeinateBar

A tiny macOS menu bar app with exactly two ways to stay awake:

| Menu item | Equivalent command | What it does |
| --- | --- | --- |
| Keep Mac Awake (-i) | `caffeinate -i` | Prevents idle system sleep |
| Keep Mac and Display Awake (-id) | `caffeinate -id` | Prevents idle system sleep and display sleep |

Pick **Off** to let the Mac sleep normally again.

## How it works

CaffeinateBar does not launch the `caffeinate` binary. It holds the same IOKit
power assertions `caffeinate` uses (`PreventUserIdleSystemSleep` and
`PreventUserIdleDisplaySleep`) directly. macOS drops those assertions the moment
the app quits or crashes, so there is never a leftover process keeping your Mac
awake.

You can confirm what it is holding with:

```sh
pmset -g assertions | grep CaffeinateBar
```

## Requirements

- macOS 14 or later
- Xcode or the Xcode Command Line Tools (`xcode-select --install`)

## Build and install

```sh
./scripts/build-app.sh            # builds build.noindex/CaffeinateBar.app
./scripts/build-app.sh --install  # also copies it to /Applications and launches it
```

The app is ad-hoc signed, which is enough to run it on the machine that built it.
It has no Dock icon; look for the cup in the menu bar.

To start it at login, add it under **System Settings > General > Login Items**.

## License

MIT
