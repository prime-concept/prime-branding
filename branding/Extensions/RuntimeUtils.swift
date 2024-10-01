import Foundation

enum ObjcAssociatedProperty {
    static func get<T>(from holder: Any, for key: UnsafeRawPointer) -> T? {
        guard let value = objc_getAssociatedObject(holder, key), value is T else {
            return nil
        }

        return value as? T
    }

    static func `set`<T>(
        _ object: T,
        to holder: Any,
        for key: UnsafeRawPointer,
        _ policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC
    ) {
        objc_setAssociatedObject(
            holder,
            key,
            object,
            policy
        )
    }
}
