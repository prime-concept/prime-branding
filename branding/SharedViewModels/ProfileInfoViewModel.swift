import Foundation

struct ProfileInfoViewModel {
    let imagePath: String
    let fullName: String
    let email: String
    let phoneNumber: String
    let balance: Int?

    var extraInfo: String {
        if phoneNumber == "" {
            return email
        }
        return phoneNumber + " · " + email
    }

    init(
        imagePath: String,
        fullName: String,
        email: String,
        phoneNumber: String,
        balance: Int? = nil
    ) {
        self.imagePath = imagePath
        self.fullName = fullName
        self.email = email
        self.phoneNumber = phoneNumber
        self.balance = balance
    }

    init(user: User, balance: Int? = nil) {
        self.imagePath = user.avatarPath
        self.email = user.email
        self.fullName = user.name
        self.phoneNumber = user.phoneNumber ?? ""
        self.balance = balance
    }
}
