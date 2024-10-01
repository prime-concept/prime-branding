import UIKit

enum ProfileRowViewModel {
    case profile(ProfileInfoViewModel)
    case item(ProfileItemViewModel, Int?)
    case achievement([Achievement], Int)
    case booking([BookingViewModel])
}
