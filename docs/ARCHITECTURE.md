# Architecture

## High-Level Structure
- UIKit app built with storyboard-based entry.
- `ViewController` orchestrates data fetching, view composition, and player lifecycle.
- `VideoView` encapsulates a single video tile and hosts `DMPlayerView`.
- Dailymotion Player SDK provides playback and ad lifecycle callbacks.

## Components And Responsibilities

### App Entry
- `AppDelegate` and `SceneDelegate` provide standard iOS lifecycle integration.
- `Info.plist` sets up a single scene using `Main.storyboard`.
- `Main.storyboard` instantiates `ViewController` as the initial controller.

### ViewController
- Builds the UI programmatically: `UIScrollView` + vertical `UIStackView`.
- Fetches a list of videos from Dailymotion’s API.
- Creates one `VideoView` per video and inserts into the stack.
- Loads the first video immediately and advances on `videoDidEnd`.
- Implements delegates:
  - `DMPlayerDelegate` for player lifecycle and errors.
  - `DMVideoDelegate` for video playback state changes.
  - `DMAdDelegate` for ad lifecycle changes.
- Updates on-screen status labels via the corresponding `VideoView` instance.

### VideoView
- Owns the thumbnail image, title, status, ad status labels.
- Creates and embeds a `DMPlayerView` using `Dailymotion.createPlayer`.
- Replaces the thumbnail with the player view when ready.
- Exposes `setStatus(...)` and `setAdStatus(...)` for UI updates.

## Data Flow
1. `ViewController` fetches video list via `fetchData(...)`.
2. JSON is mapped into `Video` structs.
3. `populateStackView(...)` creates a `VideoView` per `Video`.
4. The first `VideoView` calls `loadVideo(...)` and starts playback.
5. Delegate callbacks update UI state and log diagnostics.
6. `videoDidEnd` triggers `playNextVideo()`.

## Playback And Ad Lifecycle
- Player events update video/ad status labels.
- State and errors are logged to console for debugging.
- Errors are normalized via `handlePlayerError(...)`.

## Dependencies
- Dailymotion Player SDK via SwiftPM:
  - Source: `ios-sample-player/PlayerExample.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`

## Notes And Constraints
- The player uses a fixed `playerId = "xe5zh"`.
- Video data is pulled from a fixed Dailymotion API endpoint (limit 5).
- The list auto-advances playback, but does not autoplay new items on scroll.
