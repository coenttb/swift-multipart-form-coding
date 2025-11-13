import Foundation
import MultipartFormCoding
import URLRouting

extension Conversion {
    /// Creates a multipart form data conversion for the specified Codable type.
    ///
    /// This static method provides a convenient way to create ``Multipart.Conversion``
    /// instances for use in URLRouting route definitions.
    ///
    /// - Parameters:
    ///   - type: The Codable type to convert to/from multipart form data
    ///   - arrayEncodingStrategy: How to encode array fields (default: accumulate values)
    /// - Returns: A ``Multipart.Conversion`` instance
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct UpdateRequest: Codable {
    ///     let name: String
    ///     let subscribed: Bool
    /// }
    ///
    /// // Create conversion with default array strategy
    /// let conversion = Conversion.multipart(UpdateRequest.self)
    ///
    /// // Or with custom array strategy
    /// let conversion = Conversion.multipart(
    ///     UpdateRequest.self,
    ///     arrayEncodingStrategy: .brackets
    /// )
    /// ```
    ///
    /// ## Usage in Routes
    ///
    /// ```swift
    /// Route {
    ///     Method.put
    ///     Path { "members" / \.id }
    ///     Body(.multipart(UpdateRequest.self))
    /// }
    /// ```
    public static func multipart<Value>(
        _ type: Value.Type,
        arrayEncodingStrategy: MultipartArrayEncodingStrategy = .accumulateValues
    ) -> Self where Self == Multipart.Conversion<Value> {
        .init(type, arrayEncodingStrategy: arrayEncodingStrategy)
    }

    /// Maps this conversion through a multipart form data conversion.
    ///
    /// This method allows you to chain conversions, applying multipart form data
    /// conversion after another conversion has been applied.
    ///
    /// - Parameters:
    ///   - type: The Codable type to convert to/from multipart form data
    ///   - arrayEncodingStrategy: How to encode array fields (default: accumulate values)
    /// - Returns: A mapped conversion that applies both conversions in sequence
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Chain conversions
    /// let chainedConversion = Conversion<Data, Data>.identity
    ///     .multipart(UserProfile.self)
    /// ```
    public func multipart<Value>(
        _ type: Value.Type,
        arrayEncodingStrategy: MultipartArrayEncodingStrategy = .accumulateValues
    ) -> Conversions.Map<Self, Multipart.Conversion<Value>> {
        self.map(.multipart(type, arrayEncodingStrategy: arrayEncodingStrategy))
    }
}
