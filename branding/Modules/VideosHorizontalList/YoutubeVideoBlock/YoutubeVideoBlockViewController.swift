import AVKit
import Foundation
import Nuke
import UIKit
import YoutubeKit

final class YoutubeVideoBlockViewController: UIViewController {
    var viewModel: YoutubeVideoBlockViewModel? {
        didSet {
            if oldValue?.id != viewModel?.id {
                addYoutubeVideoPlayer()
            }
            titleLabel.text = viewModel?.title

            if let author = viewModel?.author, !author.isEmpty {
                authorLabel.text = author
            } else {
                authorLabel.isHidden = true
                self.titleLabel.snp.remakeConstraints { make in
                    make.leading.equalToSuperview().offset(15)
                    make.trailing.equalTo(self.shareButton.snp.leading).offset(-15)
                    make.bottom.equalToSuperview().offset(-15)
                }
            }

            if oldValue?.previewVideoURL != viewModel?.previewVideoURL &&
                viewModel?.previewVideoURL != nil {
                loadVideo()
                videoView.isHidden = false
                thumbnailImageView.isHidden = true
            } else if viewModel?.previewVideoURL == nil {
                videoView.isHidden = true
                thumbnailImageView.isHidden = false
                loadImage()
            }

            switch viewModel?.status ?? YoutubeVideoLiveState.none {
            case .none:
                statusContainerView.isHidden = true
            case .live:
                statusContainerView.isHidden = false
                statusImageView.image = UIImage(named: "video-status-live")
                statusLabel.text = NSLocalizedString("LiveVideoStatus", comment: "")
            case .upcoming:
                statusContainerView.isHidden = false
                statusImageView.image = UIImage(named: "video-status-notstarted")
                statusLabel.text = NSLocalizedString("UpcomingVideoStatus", comment: "")
            }

            if viewModel?.shouldShowPlayButton ?? false {
                self.view.addSubview(playBackgroundView)
                self.playBackgroundView.addSubview(self.overlayButton)
                self.playBackgroundView.snp.makeConstraints { make in
                    make.size.equalTo(CGSize(width: 55, height: 55))
                    make.center.equalToSuperview()
                }
            } else {
                self.view.insertSubview(overlayButton, belowSubview: spinnerView)
            }

            self.overlayButton.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }

    private lazy var videoView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()

    private lazy var thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()

    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .white
        return label
    }()

    private lazy var overlayButton: UIButton = {
        let button = UIButton()
        button.setTitle(nil, for: .normal)
        button.setImage(nil, for: .normal)
        button.addTarget(
            self,
            action: #selector(onVideoTap),
            for: .touchUpInside
        )
        return button
    }()

    private lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setTitle(nil, for: .normal)
        button.setImage(
            UIImage(named: "share")?.withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        button.tintColor = .white
        button.addTarget(
            self,
            action: #selector(onShareButtonTap),
            for: .touchUpInside
        )
        return button
    }()

    private lazy var statusContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private lazy var statusImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        return label
    }()

    private lazy var spinnerView: SpinnerView = {
        let spinnerView = SpinnerView()
        spinnerView.isHidden = true
        spinnerView.appearance.colorBackground = .clear
        return spinnerView
    }()

    private lazy var playBackgroundView: BlurView = {
        let view = BlurView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 27.5
        return view
    }()

    private lazy var playIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "video-play-button")
        return imageView
    }()

    private var player: AVQueuePlayer?
    private var playerLooper: AVPlayerLooper?
    private var playerLayer: AVPlayerLayer?

    private var youtubePlayer: YTSwiftyPlayer?

    override func loadView() {
        let view = UIView()

        [
            self.videoView,
            self.thumbnailImageView,
            self.dimView,
            self.titleLabel,
            self.authorLabel,
            self.statusContainerView,
            self.spinnerView,
            self.shareButton
        ].forEach(view.addSubview)

        [
            self.statusImageView,
            self.statusLabel
        ].forEach(statusContainerView.addSubview)

        playBackgroundView.addSubview(playIconImageView)

        playIconImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 15, height: 20))
            make.top.bottom.equalToSuperview().inset(17.5)
            make.leading.equalToSuperview().offset(22.5)
            make.trailing.equalToSuperview().offset(-17.5)
        }

        self.videoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.dimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.thumbnailImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.spinnerView.snp.makeConstraints { make in
            make.height.width.equalTo(35)
            make.center.equalToSuperview()
        }

        self.authorLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.bottom.equalToSuperview().offset(-15)
            make.trailing.equalTo(self.shareButton.snp.leading).offset(-15)
            make.height.equalTo(14)
        }

        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.bottom.equalTo(self.authorLabel.snp.top).offset(-5)
            make.trailing.equalTo(self.shareButton.snp.leading).offset(-15)
        }

        self.shareButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-15)
            make.trailing.equalToSuperview().offset(-15)
            make.width.height.equalTo(34)
        }

        self.statusContainerView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(15)
        }

        self.statusImageView.snp.makeConstraints { make in
            make.height.width.equalTo(12)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
        }

        self.statusLabel.snp.makeConstraints { make in
            make.height.equalTo(19)
            make.leading.equalTo(statusImageView.snp.trailing).offset(8)
            make.top.bottom.trailing.equalToSuperview()
        }

        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.clipsToBounds = true

        self.view = view
    }

    @objc
    func onShareButtonTap() {
        guard
            let id = viewModel?.id,
            let url = URL(string: "https://youtube.com/watch?v=\(id)")
        else {
            return
        }

        let shareVC = UIActivityViewController(activityItems: [url], applicationActivities: [])
        present(shareVC, animated: true)
    }

    var previousState: YTSwiftyPlayerState?

    @objc
    func onVideoTap() {
        playBackgroundView.isHidden = true
        spinnerView.isHidden = false
        playYoutubeVideo()
    }

    private func playYoutubeVideo() {
        guard let player = self.youtubePlayer else {
            fatalError("Instance of \(YTSwiftyPlayer.self) was not initialized")
        }

        self.view.addSubview(player)
        player.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        player.playVideo()
    }

    private func loadImage() {
        guard
            let viewModel = viewModel,
            let imagePath = viewModel.previewImageURL,
            let url = URL(string: imagePath)
        else {
            return
        }
        Nuke.loadImage(with: url, into: thumbnailImageView)
    }

    private func loadVideo() {
        guard
            let viewModel = viewModel,
            let videoPath = viewModel.previewVideoURL,
            let url = URL(
                string: videoPath.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
            )
        else {
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            if self.player == nil {
                let asset = AVAsset(url: url)
                let playerItem = AVPlayerItem(asset: asset)
                let player = AVQueuePlayer(playerItem: playerItem)

                self.playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)

                let playerLayer = AVPlayerLayer(player: player)
                playerLayer.frame = self.videoView.bounds
                playerLayer.videoGravity = .resizeAspectFill

                self.player = player
                self.playerLayer = playerLayer
                self.videoView.layer.addSublayer(playerLayer)
                player.isMuted = true
                player.play()
            }
        }
    }

    private func addYoutubeVideoPlayer() {
        guard let videoID = viewModel?.id else {
            return
        }
        let player = YTSwiftyPlayer(
            playerVars: [
                .videoID(videoID),
                .playsInline(false),
                .showFullScreenButton(false),
                .showRelatedVideo(false)
            ]
        )
        self.youtubePlayer = player
        player.delegate = self
        player.loadPlayer()
        spinnerView.isHidden = false
        view.isUserInteractionEnabled = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.playerLayer?.frame = self.videoView.bounds
    }

    func pauseVideo() {
        player?.pause()
    }

    func playVideo() {
        player?.play()
    }
}

extension YoutubeVideoBlockViewController: YTSwiftyPlayerDelegate {
    func player(_ player: YTSwiftyPlayer, didChangeState state: YTSwiftyPlayerState) {
        guard let prev = previousState else {
            previousState = state
            return
        }

        if prev == .buffering && state == .paused {
            youtubePlayer?.playVideo()
        }

        if state == .playing {
            spinnerView.isHidden = true
        }

        if prev == .playing && state == .paused {
            playBackgroundView.isHidden = false
            self.playVideo()
        }

        previousState = state
    }

    func playerReady(_ player: YTSwiftyPlayer) {
        spinnerView.isHidden = true
        view.isUserInteractionEnabled = true
    }
}
