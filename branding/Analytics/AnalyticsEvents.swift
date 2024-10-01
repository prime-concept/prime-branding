import Foundation

struct AnalyticsEvents {
    struct Launch {
        static var firstTime = AnalyticsEvent(name: "Launch first time")
        static var sessionStart = AnalyticsEvent(name: "Session start")
    }

    struct Share {
        static var pressed = AnalyticsEvent(name: "Share app")
    }

    struct Auth {
        static var completed = AnalyticsEvent(name: "Auth completed")
        static var opened = AnalyticsEvent(name: "Auth opened")
        static func chosen(social: String) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Auth choosed",
                parameters: [
                    "text": social
                ]
            )
        }

        static var loyaltyCompleted = AnalyticsEvent(name: "Loyality completed")
        static var loyaltyAuthCompleted = AnalyticsEvent(name: "Loyality auth completed")

        static var emailLogIn = AnalyticsEvent(name: "Auth via email opened")
        static var emailLogInCompleted = AnalyticsEvent(name: "Auth via email completed")
        static var emailSignIn = AnalyticsEvent(name: "Auth via email registration opened")
        static var emailSignInCompleted = AnalyticsEvent(name: "Auth via email registration completed")
    }

    struct Settings {
        static var opened = AnalyticsEvent(name: "Settings opened")
        static var contactPressed = AnalyticsEvent(name: "Settings contact pressed")
        static var agreementPressed = AnalyticsEvent(name: "Settings agreement pressed")
    }

    struct Profile {
        static var nameChanged = AnalyticsEvent(name: "Profile name changed")
        static var phoneChanged = AnalyticsEvent(name: "Profile phone changed")
    }

    struct Search {
        static var activated = AnalyticsEvent(name: "Search screen opened")

        static func searchedEvent(
            tag: String? = nil,
            text: String,
            position: Int,
            suggestion: String,
            date: String? = nil
        ) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Searched event",
                parameters: [
                    "tag": tag as Any,
                    "text": text,
                    "position": position,
                    "suggestion": suggestion,
                    "date": date as Any
                ]
            )
        }

        static func searchedPlace(
            text: String,
            position: Int,
            suggestion: String,
            date: String? = nil
        ) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Searched place",
                parameters: [
                    "text": text,
                    "position": position,
                    "suggestion": suggestion,
                    "date": date as Any
                ]
            )
        }

        static func searchedRestaurant(
            text: String,
            position: Int,
            suggestion: String,
            date: String? = nil
        ) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Searched restaurant",
                parameters: [
                    "text": text,
                    "position": position,
                    "suggestion": suggestion,
                    "date": date as Any
                ]
            )
        }
        static func searchedRoute(
            text: String,
            position: Int,
            suggestion: String,
            date: String? = nil
        ) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Searched route",
                parameters: [
                    "text": text,
                    "position": position,
                    "suggestion": suggestion,
                    "date": date as Any
                ]
            )
        }
    }

    struct Map {
        static var opened = AnalyticsEvent(name: "Map screen opened")
        static func tagOpened(
            title: String
        ) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Map screen tag changed",
                parameters: [
                    "text": title
                ]
            )
        }
    }

    struct Places {
        static var opened = AnalyticsEvent(name: "Places screen opened")
		static var registrationStarted = AnalyticsEvent(
			name: "Place registration started",
			parameters: ["id": "registration_start"]
		)
		static var registrationEnded = AnalyticsEvent(
			name: "Place registration ended",
			parameters: ["id": "registration_end"]
		)
    }

    struct Events {
        static var opened = AnalyticsEvent(name: "Events screen opened")
    }

    struct Place {
        static var opened = AnalyticsEvent(name: "Place screen opened")
        static var favorite = AnalyticsEvent(name: "Place favorite")
    }

    struct Event {
        static var opened = AnalyticsEvent(name: "Event screen opened")
        static var favorite = AnalyticsEvent(name: "Event favorite")
        static func calendarDateChanged(
            date: Date
        ) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Event date changed",
                parameters: [
                    "date": FormatterHelper.formatDateForServer(using: date)
                ]
            )
        }
        static var taxiPressed = AnalyticsEvent(name: "Event taxi choosed")
        static func buyTicketPressed(eventSlug: String) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Event buy ticket pressed",
                parameters: [
                    "id": eventSlug
                ]
            )
        }
        static func buyTicketDone(eventSlug: String) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Event buy ticket done",
                parameters: [
                    "id": eventSlug
                ]
            )
        }
    }

    struct Restaurant {
        static var opened = AnalyticsEvent(name: "Restaurant screen opened")
    }

    struct Restaurants {
        static var opened = AnalyticsEvent(name: "Restaurants screen opened")
    }

    struct Fest {
        static var opened = AnalyticsEvent(name: "Fest screen opened")
    }

    struct Onboarding {
        static var toSecond = AnalyticsEvent(name: "onboarding to second")
        static var toThird = AnalyticsEvent(name: "onboarding to third")
    }

    struct Quests {
        static var opened = AnalyticsEvent(name: "Quests screen opened")
    }

    struct Quest {
        static func opened(
            id: String
        ) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Quest screen opened",
                parameters: [
                    "id": id
                ]
            )
        }

        static func completed(
            question: String,
            answer: String,
            result: Bool
        ) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Quest completed",
                parameters: [
                    "question": question,
                    "answer": answer,
                    "result": result
                ]
            )
        }
    }

    struct Routes {
        static func opened(
            url: String,
            source: String
        ) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Routes screen opened",
                parameters: [
                    "url": url,
                    "source": source
                ]
            )
        }
    }

    struct Route {
        static func opened(
            source: String
        ) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Route screen opened",
                parameters: [
                    "source": source
                ]
            )
        }
    }

    struct Tickets {
        static var opened = AnalyticsEvent(
			name: "Tickets screen opened",
			parameters: ["id": "welcome_ticket"]
		)
    }

    struct Goods {
        static var opened = AnalyticsEvent(name: "Goods screen opened")
    }

    struct Good {
        static func opened(
            id: String
        ) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Good screen opened",
                parameters: [
                    "id": id
                ]
            )
        }
    }

    struct QRScan {
        static var opened = AnalyticsEvent(name: "QR screen opened")

        static func scanned(
            text: String,
            count: Int?,
            type: String,
            message: String
        ) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "QR scanned",
                parameters: [
                    "qr": text,
                    "count": count as Any,
                    "type": type,
                    "message": message
                ]
            )
        }
    }
}
