import DeckTransition
import UIKit
import WebKit

class LoyaltyGoodsListAboutViewController: UIViewController, DeckTransitionViewControllerProtocol {
    // MARK: - Private Properties
    private lazy var contentView: DeckView = {
        let view = DeckView()
        view.backgroundColor = .white
        return view
    }()

    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        view.layer.cornerRadius = 2
        return view
    }()

    private lazy var webView = WKWebView()

    private var url: URL?

    var scrollViewForDeck: UIScrollView {
        return webView.scrollView
    }

    init(url: URL?) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSubviews()
        webView.navigationDelegate = self
        if let url = url {
            webView.load(URLRequest(url: url))
        }
    }

    private func setupSubviews() {
        view.addSubview(contentView)

        contentView.addSubview(lineView)
        contentView.addSubview(webView)

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        lineView.snp.makeConstraints { make in
            make.height.equalTo(4)
            make.width.equalTo(36)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(15)
        }
        webView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(lineView.snp.bottom).offset(5)
        }
    }
}

extension LoyaltyGoodsListAboutViewController: WKNavigationDelegate {
}
