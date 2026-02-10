# Project Documentation

## Overview
This is a UIKit sample app that demonstrates embedding the Dailymotion Player SDK, fetching a list of videos from Dailymotion’s API, and playing them sequentially in a vertically scrolling list.

## Repository Map
- `ios-sample-player/README.md`  
  Project usage instructions and brief code overview.
- `ios-sample-player/LICENSE`  
  MIT License.
- `ios-sample-player/PlayerExample/AppDelegate.swift`  
  Standard app lifecycle entry point.
- `ios-sample-player/PlayerExample/SceneDelegate.swift`  
  Scene lifecycle; uses storyboard-based setup.
- `ios-sample-player/PlayerExample/ViewController.swift`  
  Main logic: fetch videos, build UI, manage player lifecycle and delegates.
- `ios-sample-player/PlayerExample/VideoView.swift`  
  Custom view that hosts the DMPlayerView, thumbnail, and status labels.
- `ios-sample-player/PlayerExample/Info.plist`  
  Scene manifest pointing to `Main.storyboard`.
- `ios-sample-player/PlayerExample/Base.lproj/Main.storyboard`  
  Initial `ViewController` scene.
- `ios-sample-player/PlayerExample/Base.lproj/LaunchScreen.storyboard`  
  Launch screen.
- `ios-sample-player/PlayerExample/Assets.xcassets/*`  
  App icons and accent color.
- `ios-sample-player/PlayerExample.xcodeproj/*`  
  Xcode project and workspace metadata.  
  Note: `xcuserdata` entries are user-specific and not part of runtime logic.
- `ios-sample-player/PlayerExample.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`  
  SwiftPM dependency lock.

## Dependencies
- Dailymotion Player SDK via Swift Package Manager:  
  - Repo: `https://github.com/dailymotion/player-sdk-ios`  
  - Version: `1.0.0` (revision `1e914e4703463b511f4d649f26ce4e9c5edee45f`)  
  Source: `ios-sample-player/PlayerExample.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`

## App Flow
1. App launches using `Main.storyboard`, which instantiates `ViewController`.
2. `ViewController` builds a `UIScrollView` containing a vertical `UIStackView`.
3. It fetches a list of 5 videos from Dailymotion’s API:
   `https://api.dailymotion.com/videos?fields=id,thumbnail_240_url,title&limit=5&owners=suaradotcom`
4. For each video, it creates a `VideoView` with thumbnail and labels.
5. The first video is immediately loaded and played using `Dailymotion.createPlayer(...)`.
6. Player events update UI labels for video/ad status.
7. When a video ends, the next video is loaded and played.

## Key Components

### ViewController
File: `ios-sample-player/PlayerExample/ViewController.swift`

Responsibilities:
- Fetch video metadata from Dailymotion API.
- Build a scrollable list of `VideoView` instances.
- Load the current video and advance to the next on end.
- Implement `DMPlayerDelegate`, `DMVideoDelegate`, and `DMAdDelegate`.

Notable behavior:
- `fetchData(...)` pulls video list and maps into `Video` structs.
- `populateStackView(...)` builds views and loads the first player.
- `playNextVideo()` increments index and loads the next item.
- Delegate callbacks update per-video status text and log state.
- Error handling via `handlePlayerError(...)`.

### VideoView
File: `ios-sample-player/PlayerExample/VideoView.swift`

Responsibilities:
- Display thumbnail and metadata labels.
- Embed the Dailymotion `DMPlayerView`.
- Provide `setStatus(...)` and `setAdStatus(...)` for UI feedback.

Notable behavior:
- `loadVideo(...)` uses `Dailymotion.createPlayer` with:
  - `playerId = "xe5zh"`
  - `mute = true`
  - `customConfig = ["customParams":"test/value=1234"]`
- When the player is created, it replaces the thumbnail with the player view.

### App / Scene Delegates
Files:
- `ios-sample-player/PlayerExample/AppDelegate.swift`
- `ios-sample-player/PlayerExample/SceneDelegate.swift`

Responsibilities:
- Standard lifecycle wiring; no custom behavior.

## UI / Storyboards
- `Main.storyboard` defines `ViewController` as the initial view controller.  
  Path: `ios-sample-player/PlayerExample/Base.lproj/Main.storyboard`
- `LaunchScreen.storyboard` provides the launch UI.  
  Path: `ios-sample-player/PlayerExample/Base.lproj/LaunchScreen.storyboard`

## Configuration
- `Info.plist` is minimal and declares the scene configuration and storyboard usage.  
  Path: `ios-sample-player/PlayerExample/Info.plist`

## Logging / Debugging
Logs in `ViewController` print:
- Player lifecycle events
- Video lifecycle events
- Ad lifecycle events
- Player state snapshots (title, id, duration, ad state, etc.)

## Running The Project
1. Open the project in Xcode.
2. Set Bundle Identifier and Team if needed.
3. Choose a device or simulator and Run.
