import Foundation

struct BookingViewModel {
    let id: String
    let title: String
    let timeSlot: String
    let status: BookingStatus
    let isVisited: Bool
    let backgroundImage: String
}

extension BookingViewModel {
    static func makeBookingViewModel(from model: Booking) -> BookingViewModel {
        let title = model.bookingData?.eventId?.title ?? ""
        let isVisited = model.bookingData?.isVisited ?? false
        var timeSlot = ""
        if let date = model.bookingData?.timeSlot,
           let tz = model.bookingData?.eventId?.eventBookingData?.placeId?.timezone.first {
            timeSlot = "\(FormatterHelper.timeWithTimeZone(from: date, timeZone: tz, format: "dd.MM")) \(LS.localize("AtTime")) \(FormatterHelper.timeWithTimeZone(from: date, timeZone: tz))"
        }
        let backgroundImage = model.bookingData?.eventId?.eventBookingData?.images.first ?? ""
        return BookingViewModel(
            id: model.id,
            title: title,
            timeSlot: timeSlot,
            status: model.status ?? BookingStatus.inactive,
            isVisited: isVisited,
            backgroundImage: backgroundImage
        )
    }
}
