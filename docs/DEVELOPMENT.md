# Development

## Requirements
- macOS with Xcode installed.
- iOS Simulator or a physical iOS device.
- Apple Developer account if signing is required.

## Open The Project
1. Open `/Users/y.satrio/Sites/ios-sample-player/PlayerExample.xcodeproj` in Xcode.
2. Select the `PlayerExample` target.

## Configure Signing (If Needed)
1. In Xcode, go to the target’s **Signing & Capabilities**.
2. Set the correct **Team** and **Bundle Identifier** for your Apple Developer account.

## Build And Run
1. Choose a simulator or connected device from the Xcode toolbar.
2. Run with `Cmd+R`.

## Runtime Data Source
- The app fetches video data from Dailymotion:
  - `https://api.dailymotion.com/videos?fields=id,thumbnail_240_url,title&limit=5&owners=suaradotcom`
- If playback is blank, verify network access and API availability.

## Debugging
- Logs include player, video, and ad lifecycle events.
- Errors are normalized in `handlePlayerError(...)` in:
  - `/Users/y.satrio/Sites/ios-sample-player/PlayerExample/ViewController.swift`

## Common Issues
- Player does not start:
  - Check if the device has network access.
  - Confirm the Dailymotion SDK dependency resolved.
- Signing errors:
  - Ensure a valid Team and unique Bundle Identifier.

## Project Files Of Interest
- `/Users/y.satrio/Sites/ios-sample-player/PlayerExample/ViewController.swift`
- `/Users/y.satrio/Sites/ios-sample-player/PlayerExample/VideoView.swift`
- `/Users/y.satrio/Sites/ios-sample-player/PlayerExample/Base.lproj/Main.storyboard`
