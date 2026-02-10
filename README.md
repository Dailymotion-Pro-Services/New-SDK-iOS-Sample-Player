# Dailymotion Player Sample Project

This is a sample project demonstrating the usage of Dailymotion Player SDK in a UIKit application.
Setup

1. Clone this repository to your local machine.
2. Open the project in Xcode.
3. If necessary, change the Bundle Identifier and Team under the target's General settings to match your Apple Developer account.

## Documentation

- [Project Documentation](docs/PROJECT.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Development](docs/DEVELOPMENT.md)

## Running the project

To run the project:

1. Connect an iPhone or iPad to your Mac, or you could use the Simulator.
2. Select your device or a simulator from the active scheme menu.
3. Press the Run button or use the Cmd+R shortcut to build and run the project on your selected device.

## Debugging

We provide logs for you to debug the player under the ViewController. We have 3 things to debug, from the player, from the video, and from the ad


## Understanding the code

The main class is ViewController, which sets up and manages the Dailymotion player. VideoView is a custom UIView subclass that loads and displays the video player.

VideoView contains a DMPlayerView instance. This instance is created by the loadVideo(withId id: String) function, which calls Dailymotion.createPlayer(). The video is played when the player view is successfully created.
