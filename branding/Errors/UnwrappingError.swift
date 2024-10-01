import Foundation

//Is used for handling unwrapping errors. Mostly useful in promises
enum UnwrappingError: Error {
    case optionalError
}
