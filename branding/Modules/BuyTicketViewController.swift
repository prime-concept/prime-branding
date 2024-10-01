import UIKit
import WebKit

protocol BuyTicketDelegate: class {
    func buyTicketsControllerDidFinish()
}

final class BuyTicketViewController: UIViewController, WKUIDelegate {
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var navigationView: UIView!

    private var url: URL?
    private weak var buyTicketDelegate: BuyTicketDelegate?

    private  var webView: WKWebView?

    init(url: URL?, buyTicketDelegate: BuyTicketDelegate?) {
        self.url = url
        self.buyTicketDelegate = buyTicketDelegate

        super.init(nibName: "BuyTicketViewController", bundle: .main)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupWebView()
        loadURL()
        setupUI()
    }

    @IBAction func backButtonTap(_ sender: Any) {
        guard let webView = webView else {
            return
        }

        if webView.canGoBack {
            webView.goBack()
        } else {
            buyTicketDelegate?.buyTicketsControllerDidFinish()
            dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func closeButtonClick(_ sender: Any) {
        buyTicketDelegate?.buyTicketsControllerDidFinish()
        dismiss(animated: true, completion: nil)
    }

    private func setupWebView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)

        guard let webView = webView else {
            return
        }
        webView.uiDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        NSLayoutConstraint.activate(
            [
                webView.topAnchor.constraint(equalTo: navigationView.bottomAnchor),
                webView.rightAnchor.constraint(equalTo: view.rightAnchor),
                webView.leftAnchor.constraint(equalTo: view.leftAnchor),
                webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ]
        )
    }

    private func loadURL() {
        guard let url = url else {
            return
        }
        let request = URLRequest(url: url)
        webView?.load(request)
    }

    private func setupUI() {
        backButton.setTitle(LS.localize("Back"), for: .normal)
        closeButton.setTitle(LS.localize("Close"), for: .normal)
        titleLabel.text = LS.localize("Tickets")
    }
}
