# Viewport-Aware Playback Scenario

This document explains the new navigation entry point and the viewport-aware playback case added alongside the existing sequential playback case.

## Summary

We added a simple home screen with link-like buttons so users can choose between two scenarios:

- **Case 1: Sequential playback** (existing behavior)
- **Case 2: Viewport-aware playback** (new behavior)

The new case automatically plays the **top-most visible** video in the scroll view and pauses the previously playing one **immediately as the user scrolls**.

## Files Added or Updated

- `/Users/y.satrio/Sites/ios-sample-player/PlayerExample/HomeViewController.swift`
- `/Users/y.satrio/Sites/ios-sample-player/PlayerExample/ViewportViewController.swift`
- `/Users/y.satrio/Sites/ios-sample-player/PlayerExample/Video.swift`
- `/Users/y.satrio/Sites/ios-sample-player/PlayerExample/VideoView.swift` (updated with play/pause helpers)
- `/Users/y.satrio/Sites/ios-sample-player/PlayerExample/SceneDelegate.swift` (updated root controller)
- `/Users/y.satrio/Sites/ios-sample-player/PlayerExample/ViewController.swift` (uses shared `VideoService`)

## Home Screen (Navigation)

**File:** `/Users/y.satrio/Sites/ios-sample-player/PlayerExample/HomeViewController.swift`

Purpose:
- Acts as a simple menu to choose a scenario.
- Uses a `UINavigationController` for push navigation.
- The buttons are styled as **link-like** text (blue + underlined) to match the user’s expectation.

Key points:
- `makeLinkButton(...)` builds a button with underlined, blue text.
- `openCase1()` pushes `ViewController` (existing case).
- `openCase2()` pushes `ViewportViewController` (new case).

## App Entry Point

**File:** `/Users/y.satrio/Sites/ios-sample-player/PlayerExample/SceneDelegate.swift`

Purpose:
- Sets the app root to the new Home screen.
- This is done programmatically so you don’t need to edit the storyboard to add the new links.

What it does:
- Creates a `UIWindow`.
- Wraps `HomeViewController` in a `UINavigationController`.
- Sets it as `window.rootViewController`.

## Shared Video Model + Fetching

**File:** `/Users/y.satrio/Sites/ios-sample-player/PlayerExample/Video.swift`

Purpose:
- Holds a simple `Video` model (id, title, thumbnail URL).
- Provides `VideoService.fetchVideos(...)` so both cases fetch data the same way.

Why:
- Avoids duplicating the API fetch logic in multiple controllers.
- Keeps `ViewController` and `ViewportViewController` focused on UI and playback behavior.

## Case 1: Sequential Playback

**File:** `/Users/y.satrio/Sites/ios-sample-player/PlayerExample/ViewController.swift`

Behavior:
- Loads a list of videos.
- Starts playing at index 0.
- When a video ends, it automatically plays the next one.

Updates:
- Uses `VideoService.fetchVideos(...)` instead of its own fetch code.
- Title set to `Case 1: Sequential` for clarity in the navigation stack.

## Case 2: Viewport-Aware Playback

**File:** `/Users/y.satrio/Sites/ios-sample-player/PlayerExample/ViewportViewController.swift`

Behavior:
- Shows the same list of videos.
- As the user scrolls, the **top-most visible** video is the only one allowed to play.
- When the top-most visible changes, the old one is paused immediately and the new one starts.

How it works:
1. The controller uses the same `UIScrollView + UIStackView` layout as Case 1.
2. On every scroll (`scrollViewDidScroll`), it calls `updatePlaybackForVisibleTop()`.
3. `topMostVisibleIndex()` returns the index of the view whose **minY is smallest** among visible items.
4. Playback switches if the selected index changes.

## VideoView Updates

**File:** `/Users/y.satrio/Sites/ios-sample-player/PlayerExample/VideoView.swift`

Added helpers:
- `playVideo(...)` to play or load if not initialized.
- `pauseVideo()` to pause the player.
- `currentVideoId` is tracked to avoid re-creating the player if it’s already loaded.

Important:
- This relies on `DMPlayerView.play()` and `DMPlayerView.pause()` being available. If the SDK version changes and those methods are named differently, adjust them here.

## Notes and Extension Ideas

- The “top-most visible” rule is simple and deterministic. If you want “most visible by area,” we can compute visible area instead of using `minY`.
- If you want switching only when scrolling stops, we can move the call to `scrollViewDidEndDragging` / `scrollViewDidEndDecelerating`.
- Both cases use `UIStackView` rather than `UITableView` or `UICollectionView`. That’s fine for a small demo list.

