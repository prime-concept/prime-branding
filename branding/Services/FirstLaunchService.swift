import Foundation

fileprivate extension String {
    static let didLaunch: String = "didLaunch"
}

protocol FirstLaunchServiceProtocol {
    func didLaunch() -> Bool
    func setDidLaunch()
    func isFirstLaunch() -> Bool
}

class FirstLaunchService: FirstLaunchServiceProtocol {
    //We need singleton, cause we have variable _isFirstLaunch, to which we should have accesss
    //during all session only in one instance
    static let shared = FirstLaunchService()

    private var defaults = UserDefaults.standard
    //We use _isFirstLaunch to tag if this session is first or not
    //default value = false
    //it changed value fo true only in setDidLaunch() method, that called only once
    //cannot use UserDefaults for it, cause it's not clear, when should change value
    private var _firstLaunch: Bool = false

    private var _didLaunch: Bool {
        get {
            return defaults.value(forKey: .didLaunch) as? Bool ?? false
        }
        set {
            defaults.set(newValue, forKey: .didLaunch)
        }
    }

    func didLaunch() -> Bool {
        return _didLaunch
    }

    func isFirstLaunch() -> Bool {
        return _firstLaunch
    }

    //This method is called oly once in AnalyticsService,
    //when app is launched for the first time
    func setDidLaunch() {
        _didLaunch = true
        _firstLaunch = true
    }
}
