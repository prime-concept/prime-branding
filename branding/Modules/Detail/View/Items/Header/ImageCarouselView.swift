import Nuke
import NukeWebPPlugin
import UIKit

final class ImageCarouselView: UIView {
    private static var completionGradientColor = UIColor(
        red: 0.13,
        green: 0.15,
        blue: 0.17,
        alpha: 0.5
    )

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        return stackView
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        return scrollView
    }()

    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.hidesForSinglePage = true
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.5)
        pageControl.isUserInteractionEnabled = false
        return pageControl
    }()

    private lazy var options = ImageLoadingOptions.cacheOptions

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        clipsToBounds = true

        addSubview(scrollView)
        scrollView.addSubview(stackView)
        addSubview(pageControl)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.attachEdges(to: self)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.attachEdges(to: scrollView)
        stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true

        pageControl.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            pageControl.topAnchor.constraint(
                equalTo: safeAreaLayoutGuide.topAnchor,
                constant: 5.5
            ).isActive = true
        } else {
            let constant = UIApplication.shared.statusBarFrame.height + 5.5
            pageControl.topAnchor.constraint(
                equalTo: topAnchor,
                constant: constant
            ).isActive = true
        }
        pageControl.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }

    private func resetStackViewSubviews() {
        for view in stackView.subviews {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
    func set(gradientImages: [DetailGradientImage]) {
        resetStackViewSubviews()
        pageControl.numberOfPages = gradientImages.count
        for index in 0..<gradientImages.count {
            // Container with image and gradient
            let containerView = UIView()
            stackView.addArrangedSubview(containerView)
            containerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
            containerView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true

            // Image
            let imageView = UIImageView()
            containerView.addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
            imageView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true

            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true

            //View with gradient
            let backgroundView = UIView()
            containerView.addSubview(backgroundView)
            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            backgroundView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
            backgroundView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true

            backgroundView.backgroundColor = gradientImages[index].gradientColor
            backgroundView.isUserInteractionEnabled = false

            loadImage(
                url: gradientImages[index].imageURL,
                view: imageView,
                gradientView: backgroundView
            )
        }
    }

    private func loadImage(url: URL, view: UIImageView, gradientView: UIView) {
        // MARK: - Need it to decode WebP image 
        WebPImageDecoder.enable()

        Nuke.loadImage(
            with: url,
            options: options,
            into: view,
            completion: { _, _ in
                gradientView.backgroundColor = ImageCarouselView.completionGradientColor
            }
        )
    }
}

extension ImageCarouselView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let witdh = scrollView.frame.width - (scrollView.contentInset.left * 2)
        let index = scrollView.contentOffset.x / witdh
        let roundedIndex = round(index)
        pageControl.currentPage = Int(roundedIndex)
    }
}
