//
//  VideoView.swift
//  PlayerExample
//
//  Created by Yudhi SATRIO on 22/05/23.
//

import Foundation
import UIKit
import DailymotionPlayerSDK

class VideoView: UIView {
    // Declare your subviews here
    private var playerView: DMPlayerView?
    private var currentVideoId: String?
    private var showError: Bool = false
    private var errorDescription: String = ""
    private var playerContainer = UIView()
    private let thumbnailImageView = UIImageView()
    private let titleLabel = UILabel()
    private let statusLabel = UILabel()
    private let adStatusLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        // Configure titleLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .light)

        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.numberOfLines = 0
        statusLabel.textAlignment = .left
        statusLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        statusLabel.textColor = .brown

        adStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        adStatusLabel.numberOfLines = 0
        adStatusLabel.textAlignment = .left
        adStatusLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        adStatusLabel.textColor = .magenta


        // Configure thumbnailImageView
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.isUserInteractionEnabled = true
        self.isUserInteractionEnabled = true
        
        // Create a vertical stack view for the labels
        let labelsStackView = UIStackView()
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        labelsStackView.axis = .vertical
        labelsStackView.distribution = .fill
        labelsStackView.spacing = 8

        labelsStackView.addArrangedSubview(titleLabel)
        labelsStackView.addArrangedSubview(statusLabel)
        labelsStackView.addArrangedSubview(adStatusLabel)



        // Add subviews to the main view
        addSubview(thumbnailImageView)
        addSubview(labelsStackView)
        
        // Add constraints to position the subviews
        NSLayoutConstraint.activate([
            thumbnailImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            thumbnailImageView.topAnchor.constraint(equalTo: topAnchor, constant: +20),
            thumbnailImageView.widthAnchor.constraint(equalTo: thumbnailImageView.heightAnchor, multiplier: 16/9),
            
            labelsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            labelsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            labelsStackView.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 8),
            labelsStackView.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor)
        ])
        
    }
    
    func loadVideo(withId id: String, playerDelegate: DMPlayerDelegate, videoDelegate: DMVideoDelegate, adDelegate: DMAdDelegate) {
        if playerView != nil {
            playerView?.play()
            return
        }
        currentVideoId = id
        var playerParams = DMPlayerParameters(mute: true)
        playerParams.customConfig = ["customParams":"test/value=1234"]
        
        let playerId = "xe5zh"

        Dailymotion.createPlayer(playerId: playerId,
                                 videoId: id,
                                 playerParameters: playerParams,
                                 playerDelegate: playerDelegate,
                                 videoDelegate: videoDelegate,
                                 adDelegate: adDelegate) { [self] createdPlayerView, error in
       
            if let playerView = createdPlayerView {
                // Add the Player View to view hierarchy
                self.addPlayerView(playerView: playerView)
            }

            if let error = error {
                self.showError = true
                self.errorDescription = error.localizedDescription
            }
        
        }
    }

    func playVideo(withId id: String, playerDelegate: DMPlayerDelegate, videoDelegate: DMVideoDelegate, adDelegate: DMAdDelegate) {
        if currentVideoId == id, playerView != nil {
            playerView?.play()
            return
        }
        loadVideo(withId: id, playerDelegate: playerDelegate, videoDelegate: videoDelegate, adDelegate: adDelegate)
    }

    func pauseVideo() {
        playerView?.pause()
    }
    
    private func addPlayerView(playerView: DMPlayerView) {
        self.playerView = playerView
        // Add the DMPlayerView as a subview to player container
        self.playerContainer.addSubview(playerView)
        
        // Set the playerView's translatesAutoresizingMaskIntoConstraints property to false
        playerView.translatesAutoresizingMaskIntoConstraints = false
        self.playerContainer.backgroundColor = .darkGray
        self.playerContainer.frame = self.bounds
        
        // Create constrains in order to keep the playerView flexible and adapt to layout changes
        let constraints = [
            playerView.topAnchor.constraint(equalTo: self.playerContainer.topAnchor, constant: 0),
            playerView.bottomAnchor.constraint(equalTo: self.playerContainer.bottomAnchor, constant: 0),
            playerView.leadingAnchor.constraint(equalTo: self.playerContainer.leadingAnchor, constant: 0),
            playerView.trailingAnchor.constraint(equalTo: self.playerContainer.trailingAnchor, constant: 0)
        ]
        // Activate created constraints
        NSLayoutConstraint.activate(constraints)

        thumbnailImageView.isHidden = true
        self.addSubview(self.playerContainer)
        self.playerView?.play()
    }
    
    func totalLabelHeight() -> CGFloat {
        let titleHeight = titleLabel.intrinsicContentSize.height
        let statusHeight = statusLabel.intrinsicContentSize.height
        let adStatusHeight = adStatusLabel.intrinsicContentSize.height
        let totalHeight = titleHeight + statusHeight + adStatusHeight
        return totalHeight
    }
    
    func setThumbnailImage(url: String?) {
        guard let urlString = url, let imageUrl = URL(string: urlString) else { return }
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: imageUrl) {
                DispatchQueue.main.async {
                    self.thumbnailImageView.image = UIImage(data: data)
                }
            }
        }
    }

    func setTitle(text: String?) {
        titleLabel.text = text
    }
    
    func setStatus(text: String?) {
        statusLabel.text = "Video status: " + (text ?? "N/A")
    }
    
    func setAdStatus(text: String?) {
        adStatusLabel.text = "Ad status: " + (text ?? "N/A")
    }
}
