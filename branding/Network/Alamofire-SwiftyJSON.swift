import Alamofire
import SwiftyJSON

/// A set of HTTP response status code that do not contain response data.
private let emptyDataStatusCodes: Set<Int> = [204, 205]

// MARK: - Request for SwiftyJSON

extension DataRequest {
    /// Creates a response serializer that
    /// returns a SwiftyJSON object result
    /// type constructed from the response data using
    /// `JSONSerialization` with the specified reading options.
    ///
    /// - parameter options: The JSON serialization reading options.
    /// Defaults to `.allowFragments`.
    ///
    /// - returns: A JSON object response serializer.
    public static func serializeResponseSwiftyJSON(
        options: JSONSerialization.ReadingOptions = .allowFragments
    ) -> DataResponseSerializer<JSON> {
            return DataResponseSerializer { _, response, data, error in
                Request.serializeResponseSwiftyJSON(
                    options: options,
                    response: response,
                    data: data,
                    error: error
                )
            }
    }

    /// Adds a handler to be called once the request has finished.
    ///
    /// - parameter options:
    ///     The JSON serialization reading options.
    /// Defaults to `.allowFragments`.
    /// - parameter completionHandler:
    /// A closure to be executed once the request has finished.
    ///
    /// - returns: The request.
    @discardableResult
    public func responseSwiftyJSON(
        queue: DispatchQueue? = nil,
        options: JSONSerialization.ReadingOptions = .allowFragments,
        _ completionHandler: @escaping (DataResponse<JSON>) -> Void
    ) -> Self {
            return response(
                queue: queue,
                responseSerializer: DataRequest.serializeResponseSwiftyJSON(
                    options: options
                ),
                completionHandler: completionHandler
            )
    }
}

// MARK: - JSON

extension Request {
    /// Returns a JSON object contained in a result type constructed
    /// from the response data using `JSONSerialization`
    /// with the specified reading options.
    ///
    /// - parameter options:  The JSON serialization reading options.
    /// Defaults to `.allowFragments`.
    /// - parameter response: The response from the server.
    /// - parameter data:     The data returned from the server.
    /// - parameter error:    The error already encountered if it exists.
    ///
    /// - returns: The result data type.
    public static func serializeResponseSwiftyJSON(
        options: JSONSerialization.ReadingOptions,
        response: HTTPURLResponse?,
        data: Data?,
        error: Error?
    ) -> Result<JSON> {
            if
                let response = response,
                emptyDataStatusCodes.contains(response.statusCode) {
                return .success(JSON.null)
            }

            guard let validData = data, !validData.isEmpty else {
                return .failure(
                    AFError.responseSerializationFailed(
                        reason: .inputDataNilOrZeroLength
                    )
                )
            }

            if let customError = makeOptionalError(with: validData, code: response?.statusCode ?? 400) {
                return .failure(customError)
            }

            if let error = error {
                return .failure(error)
            }

            do {
                let json = try JSONSerialization.jsonObject(
                    with: validData,
                    options: options
                )

                return .success(JSON(json))
            } catch {
                return .failure(
                    AFError.responseSerializationFailed(
                        reason: .jsonSerializationFailed(error: error)
                    )
                )
            }
    }

    private static func makeOptionalError(with data: Data, code: Int) -> NSError? {
        func makeNSError(code: Int, message: String) -> NSError {
            let error = NSError(
                domain: Bundle.main.bundleIdentifier ?? "",
                code: code,
                userInfo: [
                    NSLocalizedDescriptionKey: message
                ]
            )

            return error
        }

        do {
            let json = try JSONSerialization.jsonObject(
                with: data,
                options: .allowFragments
            )

            let obj = JSON(json)
            var message = ""

            if let value = obj["message"].string {
                message = value
            } else if let value = obj["errors"]["message"].string {
                message = value
            }

            return message.isEmpty ? nil : makeNSError(code: code, message: message)
        } catch {
           return nil
        }
    }
}
