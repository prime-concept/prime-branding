import Foundation

class PlistService {
    private var settings: NSDictionary?

    convenience init?(plist: String) {
        self.init()
        let bundle = Bundle(for: type(of: self) as AnyClass)
        guard let path = bundle.path(forResource: plist, ofType: "plist") else {
            return nil
        }
        guard let dic = NSDictionary(contentsOfFile: path) else {
            return nil
        }
        self.settings = dic
    }

    func get<ValueType>(for path: String) -> ValueType? {
        guard let dic = settings else {
            return nil
        }
        return dic.value(forKeyPath: path) as? ValueType
    }
}
