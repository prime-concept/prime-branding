import Foundation

enum IphoneType: String {
    case iPhoneXSMax = "iPhone11,4"
    case iPhoneXSMaxCh = "iPhone11,6"
    case iPhone8Plus = "iPhone10,2"
    case iPhone8PlusGSM = "iPhone10,5"
    case iPhone7Plus = "iPhone9,2"
    case iPhone7PlusGSM = "iPhone9,4"
    case iPhoneXR = "iPhone11,8"
    case iPhone6SPlus = "iPhone8,2"
    case iPhone6Plus = "iPhone7,1"
    case emulator = "x86_64"

    init?(rawValue: String) {
        switch rawValue {
        case IphoneType.iPhoneXSMax.rawValue:
            self = .iPhoneXSMax
        case IphoneType.iPhoneXSMaxCh.rawValue:
            self = .iPhoneXSMaxCh
        case IphoneType.iPhone8Plus.rawValue:
            self = .iPhone8Plus
        case IphoneType.iPhone8PlusGSM.rawValue:
            self = .iPhone8PlusGSM
        case IphoneType.iPhone7Plus.rawValue:
            self = .iPhone7Plus
        case IphoneType.iPhone7PlusGSM.rawValue:
            self = .iPhone7PlusGSM
        case IphoneType.iPhoneXR.rawValue:
            self = .iPhoneXR
        case IphoneType.iPhone6SPlus.rawValue:
            self = .iPhone6SPlus
        case IphoneType.iPhone6Plus.rawValue:
            self = .iPhone6Plus
        case IphoneType.emulator.rawValue:
            self = .emulator
        default:
            return nil
        }
    }
}

extension UIDevice {
    func getDeviceName() -> IphoneType? {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else {
                return identifier
            }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return IphoneType(rawValue: identifier)
    }
}
