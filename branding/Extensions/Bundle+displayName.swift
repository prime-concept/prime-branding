import Foundation

extension Bundle {
    var displayName: String {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? ""
    }

	static var isTestFlightOrSimulator: Bool {
#if targetEnvironment(simulator)
		return true
#else
		let lastPath = Bundle.main.appStoreReceiptURL?.lastPathComponent
		guard let lastPath = lastPath else {
			return true
		}

		return lastPath == "sandboxReceipt"
#endif
	}
}
