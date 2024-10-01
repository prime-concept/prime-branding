import Foundation

final class Debouncer {
    private let timeout: TimeInterval
    private var timer = Timer()
    private var action: (() -> Void)?
    private(set) var isTriggered = false

    @ThreadSafe
    private var pendingCompletions = [(() -> Void)?]()

    init(timeout: TimeInterval, isReady: Bool = true, action: @escaping () -> Void) {
        self.timeout = timeout
        self.action = { [weak self] in
            action()
            self?.pendingCompletions.forEach {
                $0?()
            }
            self?.pendingCompletions.removeAll()
            self?.isTriggered = false
        }
        if isReady {
            self.reset()
        }
    }

    func reset(addCompletion completion: (() -> Void)? = nil) {
        self.timer.invalidate()
        self.pendingCompletions.append(completion)
        self.timer = .scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self] _ in
            self?.action?()
        }
        self.isTriggered = true
    }

    func fireNow() {
        if self.timer.isValid {
            self.timer.invalidate()
            self.action?()
        }
    }

    deinit {
        self.timer.invalidate()
        self.action = nil
    }
}
