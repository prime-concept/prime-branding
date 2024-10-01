import UIKit

class ShrinkDismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    let interactionController: SwipeInteractionController?

    private let destinationFrame: CGRect

    init(destinationFrame: CGRect, interactionController: SwipeInteractionController?) {
        self.destinationFrame = destinationFrame
        self.interactionController = interactionController
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromViewController = transitionContext.viewController(forKey: .from),
            let snapshot = fromViewController.view.snapshotView(afterScreenUpdates: true)
            else {
                return
        }

        let containerView = transitionContext.containerView

        snapshot.frame = fromViewController.view.frame
        snapshot.layer.masksToBounds = true
        snapshot.layer.cornerRadius = 0
        fromViewController.view.isHidden = true

        containerView.addSubview(snapshot)

        let duration = transitionDuration(using: transitionContext)

        UIView.animate(
            withDuration: duration,
            animations: {
                snapshot.frame = self.destinationFrame
                snapshot.alpha = 0
                snapshot.layer.cornerRadius = 16
            }, completion: { _ in
                fromViewController.view.isHidden = false
                snapshot.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }
}
