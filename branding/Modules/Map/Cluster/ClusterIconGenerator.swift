import GoogleMaps

final class ClusterIconGenerator: NSObject {
    private var imageSize: CGSize {
        return  CGSize(width: 38, height: 38)
    }

    private var imageRect: CGRect {
        return CGRect(origin: .zero, size: imageSize)
    }

    private var fontSize: CGFloat {
        return 12
    }

    func icon(forSize size: UInt) -> UIImage! {
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        defer {
            UIGraphicsEndImageContext()
        }

        drawImage(number: size)

        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            return image
        } else {
            assertionFailure("Expected not to fail")
            return #imageLiteral(resourceName: "cluster_pin").tinted(with: ApplicationConfig.Appearance.firstTintColor)
        }
    }

    private func drawImage(number: UInt) {
        #imageLiteral(resourceName: "cluster_pin").tinted(with: ApplicationConfig.Appearance.firstTintColor).draw(in: imageRect)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize, weight: .semibold),
            .foregroundColor: UIColor.white,
            .paragraphStyle: paragraphStyle
        ]

        let text = "\(number)"
        text.draw(
            with: CGRect(
                x: 0,
                y: imageSize.height / 2 - fontSize / 2,
                width: imageSize.width,
                height: imageSize.height
            ),
            options: .usesLineFragmentOrigin,
            attributes: attributes,
            context: nil
        )
    }
}
