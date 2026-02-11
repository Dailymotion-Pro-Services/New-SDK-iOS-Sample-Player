import UIKit
import DailymotionPlayerSDK

class ViewportViewController: UIViewController {
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
    private var videoViews: [VideoView] = []
    private var currentPlayingIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Case 2: Viewport"
        setupUI()
        scrollView.delegate = self

        VideoService.fetchVideos { videos in
            DispatchQueue.main.async {
                self.videos = videos
                self.populateStackView(with: videos)
                self.updatePlaybackForVisibleTop()
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updatePlaybackForVisibleTop()
    }

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

    private func populateStackView(with videos: [Video]) {
        videoViews.removeAll()
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for video in videos {
            let videoView = VideoView()
            videoView.translatesAutoresizingMaskIntoConstraints = false
            videoView.setThumbnailImage(url: video.thumbnailURL.absoluteString)
            videoView.setTitle(text: video.title)
            videoView.setStatus(text: "--")
            videoView.setAdStatus(text: "--")

            stackView.addArrangedSubview(videoView)
            videoViews.append(videoView)

            NSLayoutConstraint.activate([
                videoView.heightAnchor.constraint(equalToConstant: 240),
                videoView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
                videoView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
            ])
        }

        updateStackViewSpacing()
    }

    private func updateStackViewSpacing() {
        let maxLabelHeight = videoViews.map { $0.totalLabelHeight() }.max() ?? 0
        let dynamicSpacing = maxLabelHeight + 40
        stackView.spacing = dynamicSpacing
    }

    private func updatePlaybackForVisibleTop() {
        guard !videos.isEmpty else { return }

        guard let newIndex = topMostVisibleIndex() else {
            if let current = currentPlayingIndex {
                videoViews[current].pauseVideo()
                currentPlayingIndex = nil
            }
            return
        }

        if currentPlayingIndex == newIndex {
            return
        }

        if let current = currentPlayingIndex {
            videoViews[current].pauseVideo()
        }

        currentPlayingIndex = newIndex
        let video = videos[newIndex]
        videoViews[newIndex].playVideo(withId: video.id, playerDelegate: self, videoDelegate: self, adDelegate: self)
    }

    private func topMostVisibleIndex() -> Int? {
        var topIndex: Int?
        var topY = CGFloat.greatestFiniteMagnitude

        for (index, view) in videoViews.enumerated() {
            let frame = view.convert(view.bounds, to: scrollView)
            if frame.intersects(scrollView.bounds) {
                if frame.minY < topY {
                    topY = frame.minY
                    topIndex = index
                }
            }
        }

        return topIndex
    }
}

extension ViewportViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updatePlaybackForVisibleTop()
    }
}

extension ViewportViewController: DMPlayerDelegate {
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
        handlePlayerError(error: error)
    }

    private func handlePlayerError(error: Error) {
        switch error {
        case PlayerError.advertisingModuleMissing:
            break
        case PlayerError.stateNotAvailable:
            break
        case PlayerError.underlyingRemoteError(error: let error):
            let error = error as NSError
            if let errDescription = error.userInfo[NSLocalizedDescriptionKey],
               let errCode = error.userInfo[NSLocalizedFailureReasonErrorKey],
               let recovery = error.userInfo[NSLocalizedRecoverySuggestionErrorKey] {
                print("🔥 dm: Player Error : Description: \(errDescription), Code: \(errCode), Recovery : \(recovery) ")
            } else {
                print("🔥 dm: Player Error : \(error)")
            }
        case PlayerError.requestTimedOut:
            print("🔥 dm: ", error.localizedDescription)
        case PlayerError.unexpected:
            print("🔥 dm: ", error.localizedDescription)
        case PlayerError.internetNotConnected:
            print("🔥 dm: ", error.localizedDescription)
        case PlayerError.playerIdNotFound:
            print("🔥 dm: ", error.localizedDescription)
        case PlayerError.otherPlayerRequestError:
            print("🔥 dm: ", error.localizedDescription)
        default:
            print("🔥 dm: ", error.localizedDescription)
        }
    }
}

extension ViewportViewController: DMVideoDelegate {
    func videoDidPause(_ player: DMPlayerView) {
        print("🧀 dm: video paused")
    }

    func videoDidPlay(_ player: DMPlayerView) {
        print("🧃 dm: video play")
    }

    func videoIsPlaying(_ player: DMPlayerView) {
        print("🧀 dm: video is playing")
    }

    func video(_ player: DMPlayerView, didSeekEnd time: Double) {
        print("🧀 dm: didSeekEnd: \(time)")
    }

    func videoIsBuffering(_ player: DMPlayerView) {
        print("🧀 dm: video is buffering")
    }

    func videoDidEnd(_ player: DMPlayerView) {
        print("🧃 dm: video end")
    }
}

extension ViewportViewController: DMAdDelegate {
    func adDidReceiveCompanions(_ player: DMPlayerView) {
        print("🎯 dm: ad receive companions")
    }

    func ad(_ player: DMPlayerView, didChangeDuration duration: Double) {
        print("🎯 dm: ad duration changed : \(duration)")
    }

    func ad(_ player: DMPlayerView, didEnd adEndEvent: PlayerAdEndEvent) {
        print("🎯 dm: ad end")
    }

    func adDidPause(_ player: DMPlayerView) {
        print("🎯 dm: ad pause")
    }

    func adDidPlay(_ player: DMPlayerView) {
        print("🎯 dm: ad play")
    }

    func ad(_ player: DMPlayerView, didStart type: String, _ position: String) {
        print("🎯 dm: ad start, Type: \(type), Pos: \(position)")
    }

    func ad(_ player: DMPlayerView, adDidLoaded adLoadedEvent: PlayerAdLoadedEvent) {
        print("🎯 dm: Loaded")
    }

    func adDidClick(_ player: DMPlayerView) {
        print("🎯 dm: Click")
    }
}
