import Foundation

@propertyWrapper
final class ThreadSafe<ValueType> {
    private let isolationQueue: DispatchQueue
    private var value: ValueType

    init(wrappedValue: ValueType) {
        self.isolationQueue = DispatchQueue(label: "ThreadSafeBox_\(wrappedValue.self)_\(UUID().uuidString)", attributes: .concurrent)
        self.value = wrappedValue
    }

    var wrappedValue: ValueType {
        get {
            var result: ValueType? = nil
            self.isolationQueue.sync {
                result = self.value
            }
            return result!
        }

        set {
            self.isolationQueue.async(flags: .barrier) {
                self.value = newValue
            }
        }
    }
}
