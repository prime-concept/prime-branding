import UIKit

class CurtainView: UIView {
	struct Appearance {
		var curtainColor: UIColor = .white
		var grabberColor: UIColor = .gray

		var curtainCornerRadius: CGFloat = 20
		var grabberSize: CGSize = CGSize(width: 40, height: 4)
	}

	var magneticRatios: [CGFloat] = [0.5]
	var toggleRatio: CGFloat = 0.3

	var mimicksFullscreenWhenExpanded: Bool = false
	var hidesOnPanToBottom: Bool = false

	var willAnimateMagneticScroll: ((CGFloat, CGFloat) -> Void)? = nil
	var animateAlongsideMagneticScroll: ((CGFloat, CGFloat) -> Void)? = nil
	var didAnimateMagneticScroll: ((CGFloat, CGFloat) -> Void)? = nil
	var didPan: ((CGFloat) -> Void)? = nil

	var currentRatio: CGFloat {
		if let constraint = self.curtainTopConstraint {
			return 1 - constraint.constant / self.bounds.height
		}
		return 0
	}

	private let appearance: Appearance
	private(set) var content: UIView
	private var isAnimating: Bool = false

	private var contentInset: UIEdgeInsets
	private var contentTopConstraint: NSLayoutConstraint!
	private var curtainTopConstraint: NSLayoutConstraint!

	private var latestTranslationY: CGFloat? = nil {
		willSet {
			self.previousTranslationY = self.latestTranslationY
		}
	}

	private var previousTranslationY: CGFloat? = nil

	private var isGoingUp: Bool {
		guard let previous = self.previousTranslationY, let current = self.latestTranslationY else {
			return false
		}

		return previous > current
	}

	private(set) lazy var curtain = UIView { curtain in
		let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
		curtain.addGestureRecognizer(panRecognizer)
		curtain.isUserInteractionEnabled = true
		curtain.layer.masksToBounds = true
	}

	private(set) lazy var grabber = UIView()

	init(
		appearance: Appearance = Appearance(),
		content: UIView,
		contentInset: UIEdgeInsets = .init(top: 20, left: 0, bottom: 0, right: 0),
		initialRatio: CGFloat = 1.0
	) {
		self.appearance = appearance
		self.content = content
		self.contentInset = contentInset

		super.init(frame: .zero)

		self.addSubview(self.curtain)
		self.curtain.addSubview(content)

		self.setupCurtain()
		self.setupGrabber()

		self.contentTopConstraint = content.make(.edges, .equalToSuperview, [
			contentInset.top,
			contentInset.left,
			contentInset.bottom,
			contentInset.right
		])[0]

		self.scrollTo(ratio: initialRatio, animated: false)
	}

	private func setupCurtain() {
		self.curtain.make(.edges(except: .top), .equalToSuperview)
		self.curtainTopConstraint = self.curtain.make(.top, .lessThanOrEqualToSuperview, priority: .defaultHigh)
		self.curtain.backgroundColor = self.appearance.curtainColor
		self.curtain.layer.cornerRadius = self.appearance.curtainCornerRadius
		self.curtain.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
	}

	private func setupGrabber() {
		self.curtain.addSubview(self.grabber)

		self.grabber.backgroundColor = self.appearance.grabberColor
		self.grabber.layer.cornerRadius = self.appearance.grabberSize.height / 2

		self.grabber.make(.top, .equalToSuperview, 10)
		self.grabber.make(.centerX, .equalToSuperview)
		self.grabber.make(.size, .equal, [self.appearance.grabberSize.width, self.appearance.grabberSize.height])
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
		self.curtain.frame.contains(point)
	}

	func scrollTo(ratio: CGFloat, animated: Bool = true) {
		self.setNeedsLayout()
		self.willAnimateMagneticScroll?(ratio, 0)
		let top = (1 - ratio) * self.bounds.height
		self.curtainTopConstraint.constant = top
		UIView.animate(withDuration: animated ? 0.5 : 0, animations: {
			self.layoutIfNeeded()
			self.animateAlongsideMagneticScroll?(ratio, 0)
			self.changeFullscreenStateIfNeeded()
		}) { _ in
			self.didAnimateMagneticScroll?(ratio, 0)
			self.didPan?(ratio)
		}
	}

	@objc
	private func onPan(_ recognizer: UIPanGestureRecognizer) {
		let view = recognizer.view

		let velocityY = recognizer.velocity(in: self).y
		let locationY = recognizer.location(in: self).y

		if locationY < 0 || locationY >= self.bounds.height - self.contentInset.top {
			self.scrollToNearestMagneticPoint()
			self.latestTranslationY = nil
			return
		}

		switch recognizer.state {
			case .ended, .failed, .cancelled:
				self.scrollToNearestMagneticPoint(velocity: velocityY)
				self.latestTranslationY = nil
				return
			default:
				break
		}

		let translationY = recognizer.translation(in: view).y
		defer {
			self.latestTranslationY = translationY
			self.didPan?(1 - (self.curtainTopConstraint.constant / self.bounds.height))
			self.changeFullscreenStateIfNeeded()
		}

		guard let latestTranslationY = self.latestTranslationY else {
			return
		}

		let delta = latestTranslationY - translationY
		var newTop = self.curtainTopConstraint.constant - delta
		newTop = max(0, newTop)
		newTop = min(newTop, self.bounds.height - self.contentInset.top)

		self.curtainTopConstraint.constant = newTop
	}

	private func changeFullscreenStateIfNeeded() {
		guard self.mimicksFullscreenWhenExpanded else {
			return
		}

		let currentRatio = self.currentRatio

		var shouldMimickFullscreen = currentRatio > 0.95 && self.curtain.layer.cornerRadius != 0
		shouldMimickFullscreen = shouldMimickFullscreen || (currentRatio != currentRatio)

		let shouldResignFullscreen = currentRatio <= 0.95 && self.curtain.layer.cornerRadius == 0

		guard shouldResignFullscreen || shouldMimickFullscreen else {
			return
		}
		
		UIView.animate(withDuration: 0.25) {
			self.curtain.layer.cornerRadius = shouldMimickFullscreen ? 0 : self.appearance.curtainCornerRadius
			self.grabber.alpha = shouldMimickFullscreen ? 0 : 1
		}
	}

	private func scrollToNearestMagneticPoint(
		duration: TimeInterval = 0.3,
		velocity: CGFloat = 0
	) {
		if self.isAnimating {
			return
		}

		var nearestY: CGFloat? = nil
		let currentY = self.curtainTopConstraint.constant

		let magneticYs = Set(self.magneticRatios)
			.union(hidesOnPanToBottom ? [0, 1] : [1])
			.map { 1 - $0 }
			.sorted(by: <)
			.map { (1 - $0, $0 * self.bounds.height) }

		if currentY < magneticYs.first!.1 {
			nearestY = magneticYs.first!.1
		} else if currentY > magneticYs.last!.1 {
			nearestY = magneticYs.last!.1
		} else {
			for i in 0..<magneticYs.count - 1 {
				let firstY = magneticYs[i].1
				let secondY = magneticYs[i + 1].1
				guard currentY > firstY, currentY < secondY else {
					continue
				}

				if velocity > 1000 {
					nearestY = secondY
					break
				}

				if velocity < -1000 {
					nearestY = firstY
					break
				}

				let interval = secondY - firstY
				let translation1 = abs(firstY - currentY)

				nearestY = firstY

				if self.isGoingUp {
					if translation1 > (1 - self.toggleRatio) * interval {
						nearestY = secondY
					}
				} else {
					if translation1 > self.toggleRatio * interval {
						nearestY = secondY
					}
				}

				break
			}
		}

		guard let nearestY = nearestY else {
			return
		}

		let magenticRatio = magneticYs.first(where: { $0.1 == nearestY })!.0

		var duration = duration
		let travelDistance = abs(self.curtainTopConstraint.constant - nearestY)

		if travelDistance != 0 {
			duration = (travelDistance / (UIScreen.main.bounds.height / 2)) * 0.5
		} else if abs(velocity) > 1000 {
			duration = travelDistance / velocity
		}

		self.curtainTopConstraint.constant = nearestY

		self.willAnimateMagneticScroll?(magenticRatio, duration)
		self.isAnimating = true

		let shouldMimickFullscreen = (nearestY == 0) && self.mimicksFullscreenWhenExpanded
		self.contentTopConstraint.constant = shouldMimickFullscreen ? 0 : self.contentInset.top

		self.setNeedsLayout()
		
		UIView.animate(withDuration: duration, animations: {
			self.layoutIfNeeded()
			self.animateAlongsideMagneticScroll?(magenticRatio, duration)
			self.changeFullscreenStateIfNeeded()
		}, completion: { _ in
			self.isAnimating = false
			self.didAnimateMagneticScroll?(magenticRatio, duration)
		})
	}
}
