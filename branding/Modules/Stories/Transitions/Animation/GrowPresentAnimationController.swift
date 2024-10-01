import UIKit

class GrowPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    private let originFrame: CGRect

    init(originFrame: CGRect) {
        self.originFrame = originFrame
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to) else {
            return
        }

        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toViewController)

        toViewController.view.frame = originFrame
        toViewController.view.layer.masksToBounds = true
        toViewController.view.alpha = 0

        containerView.addSubview(toViewController.view)
        let duration = transitionDuration(using: transitionContext)

        UIView.animate(
            withDuration: duration,
            animations: {
                toViewController.view.frame = finalFrame
                toViewController.view.layoutSubviews()
                toViewController.view.alpha = 1
            }, completion: { _ in
                toViewController.view.alpha = 1
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }
}
