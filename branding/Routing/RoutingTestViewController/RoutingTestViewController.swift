import Foundation
import UIKit

class RoutingTestViewController: UIViewController {
    @IBOutlet weak var testTextLabel: UILabel!

    var testText: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        testTextLabel.text = testText
    }
}
