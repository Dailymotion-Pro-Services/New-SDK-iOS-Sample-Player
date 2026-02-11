//
//  ViewController.swift
//  PlayerExample
//
//  Created by Yudhi SATRIO on 22/05/23.
//

import UIKit
import DailymotionPlayerSDK

class ViewController: UIViewController {
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 40
        return stackView
    }()
    private var videos: [Video] = []
    private var currentPlayingVideoIndex = 0
    private var postroll = false
    private var videoend = false
    private var videoViews: [VideoView] = []
    var videoView: VideoView?
    
    func updateVideoView() {
        videoView = stackView.arrangedSubviews[currentPlayingVideoIndex] as? VideoView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Case 1: Sequential"
        setupUI()
        
        VideoService.fetchVideos { videos in
            DispatchQueue.main.async {
                self.videos = videos
                self.populateStackView(with: videos)
            }
        }
    }
    
    /// Sets up the user interface by configuring the main view, scroll view, and stack view.
    ///
    /// This function is responsible for:
    /// - Setting the main view's background color to white.
    /// - Adding the scroll view as a subview of the main view and setting its constraints.
    /// - Adding the stack view as a subview of the scroll view and setting its constraints.
    /// - Ensuring that the stack view has the same width as the scroll view.
    ///
    /// By organizing the UI elements in this way, the interface can efficiently display and scroll through a dynamic list of content.
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    /// Populates the stack view with VideoView instances created from the given array of videos.
    ///
    /// - Parameter videos: An array of `Video` objects representing the videos to display in the stack view.
    ///
    /// This function does the following:
    /// - Iterates through each `Video` object in the provided `videos` array.
    /// - Creates a new `VideoView` instance for each video and sets the thumbnail image and title.
    /// - Loads the video with the provided `video.id` if the current index matches `currentPlayingVideoIndex`.
    /// - Adds the `VideoView` instance to the stack view as an arranged subview.
    /// - Sets the height, leading, and trailing constraints for the `VideoView` instance.
    ///
    /// By using this function, the interface can efficiently display multiple video views in a scrollable stack view.
    private func populateStackView(with videos: [Video]) {
        for (index, video) in videos.enumerated() {
            let videoView = VideoView()
            videoView.translatesAutoresizingMaskIntoConstraints = false
            videoView.setThumbnailImage(url: video.thumbnailURL.absoluteString)
            videoView.setTitle(text: video.title)
            videoView.setStatus(text: "--")
            videoView.setAdStatus(text: "--")
            
            stackView.addArrangedSubview(videoView)
            
            NSLayoutConstraint.activate([
                videoView.heightAnchor.constraint(equalToConstant: 240),
                videoView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
                videoView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            ])
            
            if index == currentPlayingVideoIndex {
                videoView.loadVideo(withId: video.id, playerDelegate: self, videoDelegate: self, adDelegate: self)
            }
        }
        
        // Update the stack view's spacing after adding all the VideoViews
        updateStackViewSpacing()
    }
    
    /// Plays the next video in the list and scrolls to its position.
    ///
    /// This function checks if there is a next video available in the `videos` array by comparing
    /// `currentPlayingVideoIndex` with the total number of videos.
    ///
    /// If there is a next video:
    /// - It increments `currentPlayingVideoIndex`.
    /// - Retrieves the `Video` object for the next video.
    /// - Obtains the corresponding `VideoView` instance from the `stackView.arrangedSubviews`.
    /// - Loads the next video with the provided `nextVideo.id` and sets the delegate to `self`.
    /// - Calls `scrollToVideoPlayingPosition()` to scroll the view to the video's position.
    ///
    /// By using this function, you can easily switch to the next video in the list and automatically
    /// scroll the view to display the currently playing video.
    private func playNextVideo() {
        if currentPlayingVideoIndex + 1 < videos.count {
            currentPlayingVideoIndex += 1
            let nextVideo = videos[currentPlayingVideoIndex]
            let nextVideoView = stackView.arrangedSubviews[currentPlayingVideoIndex] as! VideoView
            nextVideoView.loadVideo(withId: nextVideo.id, playerDelegate: self, videoDelegate: self, adDelegate: self)
//            scrollToVideoPlayingPosition()
            resetVideoFlags()
        }
    }
    
    /// Scrolls the view to the currently playing video's position.
    ///
    /// This function checks if the `currentPlayingVideoIndex` is within the range of the `videos` array.
    ///
    /// If the index is within range:
    /// - It retrieves the corresponding `VideoView` instance from the `stackView.arrangedSubviews`.
    /// - Converts the `videoView`'s bounds to the coordinate system of the `scrollView`.
    /// - Sets the content offset of the `scrollView` to the origin of the converted `videoView` frame
    ///   with a smooth animation.
    ///
    /// By using this function, you can ensure that the view automatically scrolls to display the
    /// currently playing video, improving the user experience and making video navigation more convenient.
    private func scrollToVideoPlayingPosition() {
        if currentPlayingVideoIndex < videos.count {
            let videoView = stackView.arrangedSubviews[currentPlayingVideoIndex] as! VideoView
            let videoViewFrame = videoView.convert(videoView.bounds, to: scrollView)
            scrollView.setContentOffset(CGPoint(x: 0, y: videoViewFrame.origin.y), animated: true)
        }
    }

    func updateStackViewSpacing() {
        // Get all the VideoView instances from the stack view's arrangedSubviews
        let videoViews = stackView.arrangedSubviews.compactMap { $0 as? VideoView }

        // Calculate the maximum total height of the labels for all VideoViews
        let maxLabelHeight = videoViews.map { $0.totalLabelHeight() }.max() ?? 0

        // Add some padding (e.g., 20) to the maximum height to ensure proper spacing
        let dynamicSpacing = maxLabelHeight + 40

        // Update the stack view's spacing
        stackView.spacing = dynamicSpacing
    }
    
    // Create a function to reset the variables
    private func resetVideoFlags() {
        postroll = false
        videoend = false
    }


    func handlePlayerError(error: Error) {
      switch(error) {
        case PlayerError.advertisingModuleMissing :
          break;
        case PlayerError.stateNotAvailable :
          break;
        case PlayerError.underlyingRemoteError(error: let error):
          let error = error as NSError
          if let errDescription = error.userInfo[NSLocalizedDescriptionKey],
             let errCode = error.userInfo[NSLocalizedFailureReasonErrorKey],
             let recovery = error.userInfo[NSLocalizedRecoverySuggestionErrorKey] {
            print("🔥 dm: Player Error : Description: \(errDescription), Code: \(errCode), Recovery : \(recovery) ")
            
          } else {
            print("🔥 dm: Player Error : \(error)")
          }
          break
        case PlayerError.requestTimedOut:
          print("🔥 dm: ", error.localizedDescription)
          break
        case PlayerError.unexpected:
          print("🔥 dm: ", error.localizedDescription)
          break
        case PlayerError.internetNotConnected:
          print("🔥 dm: ", error.localizedDescription)
          break
        case PlayerError.playerIdNotFound:
          print("🔥 dm: ", error.localizedDescription)
          break
        case PlayerError.otherPlayerRequestError:
          print("🔥 dm: ", error.localizedDescription)
          break
        default:
          print("🔥 dm: ", error.localizedDescription)
          break
      }
    }
    
    
    func showPlayerState(player: DMPlayerView) {
        player.getState() { state in
            print("    🥞 dm: video title -", state?.videoTitle ?? "null")
            print("    🥞 dm: video id -", state?.videoId ?? "null")
            print("    🥞 dm: video duration -", state?.videoDuration ?? "")
            print("    🥞 dm: player muted -", state?.playerIsMuted ?? "null")
            print("    🥞 dm: ad companion -", state?.adCompanion ?? "null")
            print("    🥞 dm: ad error -", state?.adError ?? "null")
            print("    🥞 dm: ad end reason -", state?.adEndedReason ?? "null")
            print("    🥞 dm: ad position -", state?.adPosition ?? "null")
        }
    }
}


extension ViewController: DMPlayerDelegate {
    
    func player(_ player: DMPlayerView, openUrl url: URL) {
        UIApplication.shared.open(url)
    }
    
    func playerWillPresentFullscreenViewController(_ player: DailymotionPlayerSDK.DMPlayerView) -> UIViewController {
        return self
    }
    
    func playerWillPresentAdInParentViewController(_ player: DailymotionPlayerSDK.DMPlayerView) -> UIViewController {
        return self
    }
    
    func playerDidStart(_ player: DMPlayerView) {
      print("🧃 dm: player start")
      showPlayerState(player: player)
    }
    
    func playerDidEnd(_ player: DMPlayerView) {
      print("🧃 dm: player end")
    }
    
    func playerDidCriticalPathReady(_ player: DMPlayerView) {
      print("🧃 dm: playback ready")
    }
    
    func player(_ player: DMPlayerView, didReceivePlaybackPermission playbackPermission: PlayerPlaybackPermission) {
      print("🧀 dm: playback permission : status:\(playbackPermission.status), reason:\(playbackPermission.reason)")
    }
    
    func player(_ player: DMPlayerView, didFailWithError error: Error) {
      self.handlePlayerError(error: error)
    }
}


extension ViewController: DMVideoDelegate {

//    func video(_ player: DMPlayerView, didChangeSubtitles subtitles: String) {
//        print("🧃 dm: video subtitle change : \(subtitles)")
//    }
//
//    func video(_ player: DMPlayerView, didReceiveSubtitlesList subtitlesList: [String]) {
//        print("🧃 dm: video subtitle list available: \(subtitlesList)")
//    }
//
//    func video(_ player: DMPlayerView, didChangeDuration duration: Double) {
//        print("🧀 dm: Duration changed: \(duration)")
//    }

    func videoDidEnd(_ player: DMPlayerView) {
        updateVideoView()
        videoView?.setStatus(text: "end")
        self.playNextVideo()
        print("🧃 dm: video end", player)
        showPlayerState(player: player)
    }

    func videoDidPause(_ player: DMPlayerView) {
        updateVideoView()
        videoView?.setStatus(text: "pause")
        print("🧀 dm: video paused")
    }

    func videoDidPlay(_ player: DMPlayerView) {
        updateVideoView()
        videoView?.setStatus(text: "start play")
        print("🧃 dm: video play")
    }

    func videoIsPlaying(_ player: DMPlayerView) {
        updateVideoView()
        videoView?.setStatus(text: "playing")
        print("🧀 dm: video is playing")
    }

//    func video(_ player: DMPlayerView, isInProgress progressTime: Double) {
//        print("🧀 dm: video is in progress: \(progressTime)")
//    }
//
//    func video(_ player: DMPlayerView, didReceiveQualitiesList qualities: [String]) {
//        print("🧀 dm: video qualities Available: \(qualities)")
//    }
//
//    func video(_ player: DMPlayerView, didSeekStart time: Double) {
//        print("🧀 dm: didSeekStart: \(time)")
//    }

    func video(_ player: DMPlayerView, didSeekEnd time: Double) {
        updateVideoView()
        videoView?.setStatus(text: "seeking")
        print("🧀 dm: didSeekEnd: \(time)")
    }

//    func video(_ player: DMPlayerView, didChangeQuality quality: String) {
//        print("🧃 dm: quality changed: \(quality)")
//    }
//
//    func videoDidStart(_ player: DMPlayerView){
//        print("🧃 dm: video did start")
//    }

//    func video(_ player: DMPlayerView, didChangeTime time: Double) {
//            print("🧀 dm: " + String(format: "Time: %.2f", time))
//    }

    func videoIsBuffering(_ player: DMPlayerView) {
        updateVideoView()
        videoView?.setStatus(text: "buffering")
        print("🧀 dm: video is buffering")
    }
}


// state available: adIsPlaying,  adPosition , adEndReason, adError
extension ViewController: DMAdDelegate {
    func adDidReceiveCompanions(_ player: DMPlayerView) {
        print("🎯 dm: ad receive companions")
        showPlayerState(player: player)
    }

    func ad(_ player: DMPlayerView, didChangeDuration duration: Double) {
        print("🎯 dm: ad duration changed : \(duration)")
    }

    func ad(_ player: DMPlayerView, didEnd adEndEvent: PlayerAdEndEvent) {
        updateVideoView()
        videoView?.setAdStatus(text: "end")
        print("🎯 dm: ad end")
        showPlayerState(player: player)
    }

    func adDidPause(_ player: DMPlayerView) {
        updateVideoView()
        videoView?.setAdStatus(text: "pause")
        print("🎯 dm: ad pause")
    }

    func adDidPlay(_ player: DMPlayerView) {
        updateVideoView()
        videoView?.setAdStatus(text: "play")
        print("🎯 dm: ad play")
    }

    func ad(_ player: DMPlayerView, didStart type: String, _ position: String) {
        updateVideoView()
        videoView?.setAdStatus(text: "start")
        print("🎯 dm: ad start, Type: \(type), Pos: \(position)")
        showPlayerState(player: player)
    }

//    func ad(_ player: DMPlayerView, didChangeTime time: Double) {
//        print("🎯 dm: ad time changed : \(time)")
//    }
//
//    func adDidImpression(_ player: DMPlayerView) {
//        print("🎯 dm: Impression")
//    }

    func ad(_ player: DMPlayerView, adDidLoaded adLoadedEvent: PlayerAdLoadedEvent) {
        updateVideoView()
        videoView?.setAdStatus(text: "loaded")
        print("🎯 dm: Loaded")
    }

    func adDidClick(_ player: DMPlayerView) {
        updateVideoView()
        videoView?.setAdStatus(text: "clicked")
        print("🎯 dm: Click")
    }
}
