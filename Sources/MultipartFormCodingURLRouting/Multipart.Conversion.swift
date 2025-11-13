import Foundation
import RFC_2045
import RFC_2046
import RFC_7578
import MultipartFormCoding
import URLRouting

/// A conversion that handles multipart/form-data encoding for Codable types.
///
/// `Multipart.Conversion` provides automatic conversion from Swift Codable types to
/// multipart/form-data format, commonly used by APIs like Mailgun that require this
/// encoding for non-file fields.
///
/// ## Usage
///
/// ```swift
/// struct UpdateRequest: Codable {
///     let name: String
///     let subscribed: Bool
///     let vars: [String: String]?
/// }
///
/// let conversion = Multipart.Conversion(UpdateRequest.self)
///
/// // Use in route definition
/// Route {
///     Method.put
///     Path { "members" / \.id }
///     Body(conversion)
/// }
/// ```
///
/// ## Array Encoding Strategies
///
/// - `.accumulateValues`: Repeats field name for each value (Mailgun style)
///   ```
///   --boundary
///   Content-Disposition: form-data; name="tags"
///
///   swift
///   --boundary
///   Content-Disposition: form-data; name="tags"
///
///   ios
///   ```
///
/// - `.brackets`: Uses empty brackets notation (PHP/Rails style)
///   ```
///   --boundary
///   Content-Disposition: form-data; name="tags[]"
///
///   swift
///   ```

/// Strategy for encoding arrays in multipart fields.
public enum MultipartArrayEncodingStrategy: Sendable {
    /// Repeats the field name for each array element.
    /// Example: `name="tags"\r\n\r\nswift\r\n...name="tags"\r\n\r\nios`
    case accumulateValues

    /// Appends empty brackets to field name.
    /// Example: `name="tags[]"\r\n\r\nswift\r\n...name="tags[]"\r\n\r\nios`
    case brackets
}

extension Multipart {
    public struct Conversion<Value: Codable>: @unchecked Sendable {
        /// The unique boundary string used to separate multipart fields.
        public let boundary: String

        /// Strategy for encoding arrays in multipart fields.
        public let arrayEncodingStrategy: MultipartArrayEncodingStrategy

        /// Creates a new multipart form coding conversion.
        ///
        /// - Parameters:
        ///   - type: The Codable type to convert to/from
        ///   - arrayEncodingStrategy: How to encode array fields (default: accumulate values)
        public init(
            _ type: Value.Type,
            arrayEncodingStrategy: MultipartArrayEncodingStrategy = .accumulateValues
        ) {
            self.boundary = RFC_2046.Multipart.generateBoundary()
            self.arrayEncodingStrategy = arrayEncodingStrategy
        }

        /// The Content-Type header value for multipart/form-data requests.
        ///
        /// Returns a string in the format: `multipart/form-data; boundary=<unique-boundary>`
        public var contentType: String {
            "multipart/form-data; boundary=\(boundary)"
        }
    }
}

extension Multipart.Conversion: URLRouting.Conversion {
    /// Converts multipart form data to a Swift value.
    ///
    /// - Parameter input: The form data to decode
    /// - Returns: The decoded Swift value
    /// - Throws: Decoding errors
    ///
    /// - Note: This is a basic implementation. For robust parsing of actual multipart data,
    ///   consider using a dedicated multipart parser.
    public func apply(_ input: Data) throws -> Value {
        // For now, this is a placeholder. Full multipart parsing is complex.
        // In practice, most APIs only need the `unapply` direction (encoding).
        throw MultipartConversionError.decodingNotImplemented
    }

    /// Converts a Swift value to multipart form data.
    ///
    /// This method encodes the Swift value to RFC 7578-compliant multipart/form-data
    /// format using the RFC 2046 Multipart implementation.
    ///
    /// - Parameter output: The Swift value to encode
    /// - Returns: The multipart form data as `Data`
    /// - Throws: Encoding errors
    public func unapply(_ output: Value) throws -> Foundation.Data {
        // Step 1: Extract field→value pairs using our custom encoder
        let encoder = MultipartFieldEncoder(arrayStrategy: arrayEncodingStrategy)
        try output.encode(to: encoder)

        // Step 2: Convert each field to an RFC_2046.BodyPart
        let parts: [RFC_2046.BodyPart] = encoder.fields.map { field in
            // Use RFC_7578 for proper Content-Disposition header formatting
            // This handles escaping of special characters in field names per RFC 2183/RFC 2231
            let contentDisposition = RFC_7578.FormData.escapeContentDisposition(
                name: field.name
            )

            // Create BodyPart with Content-Disposition header and text content
            return RFC_2046.BodyPart(
                headers: ["Content-Disposition": contentDisposition],
                text: field.value
            )
        }

        // Step 3: Build RFC 2046-compliant multipart message
        let multipart = try RFC_2046.Multipart(
            subtype: .formData,
            parts: parts,
            boundary: boundary
        )

        // Step 4: Render to RFC-compliant format with CRLF line endings
        let rendered = multipart.render()

        // Step 5: Convert to Data
        guard let data = rendered.data(using: .utf8) else {
            throw MultipartConversionError.encodingFailed
        }

        return data
    }
}

/// Errors that can occur during multipart conversion.
public enum MultipartConversionError: Error, LocalizedError {
    case encodingFailed
    case decodingNotImplemented

    public var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Failed to encode value as multipart/form-data"
        case .decodingNotImplemented:
            return "Decoding from multipart/form-data is not yet implemented"
        }
    }
}

// MARK: - Custom Encoder for Field Extraction

/// Internal encoder that extracts field names and values from Codable types.
private class MultipartFieldEncoder: Encoder {
    var fields: [MultipartField] = []
    let arrayStrategy: MultipartArrayEncodingStrategy
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey: Any] = [:]

    init(arrayStrategy: MultipartArrayEncodingStrategy) {
        self.arrayStrategy = arrayStrategy
    }

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
        let container = MultipartKeyedEncodingContainer<Key>(
            encoder: self,
            codingPath: codingPath,
            arrayStrategy: arrayStrategy
        )
        return KeyedEncodingContainer(container)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError("Unkeyed containers at root level not supported for multipart encoding")
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        MultipartSingleValueEncodingContainer(encoder: self, codingPath: codingPath)
    }
}

private struct MultipartField {
    let name: String
    let value: String
}

private struct MultipartKeyedEncodingContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
    let encoder: MultipartFieldEncoder
    var codingPath: [CodingKey]
    let arrayStrategy: MultipartArrayEncodingStrategy

    mutating func encodeNil(forKey key: Key) throws {
        // Skip nil values
    }

    mutating func encode(_ value: Bool, forKey key: Key) throws {
        let stringValue = value ? "true" : "false"
        encoder.fields.append(MultipartField(name: key.stringValue, value: stringValue))
    }

    mutating func encode(_ value: String, forKey key: Key) throws {
        encoder.fields.append(MultipartField(name: key.stringValue, value: value))
    }

    mutating func encode(_ value: Int, forKey key: Key) throws {
        encoder.fields.append(MultipartField(name: key.stringValue, value: String(value)))
    }

    mutating func encode(_ value: Double, forKey key: Key) throws {
        encoder.fields.append(MultipartField(name: key.stringValue, value: String(value)))
    }

    mutating func encode(_ value: Float, forKey key: Key) throws {
        encoder.fields.append(MultipartField(name: key.stringValue, value: String(value)))
    }

    mutating func encode(_ value: Int8, forKey key: Key) throws {
        encoder.fields.append(MultipartField(name: key.stringValue, value: String(value)))
    }

    mutating func encode(_ value: Int16, forKey key: Key) throws {
        encoder.fields.append(MultipartField(name: key.stringValue, value: String(value)))
    }

    mutating func encode(_ value: Int32, forKey key: Key) throws {
        encoder.fields.append(MultipartField(name: key.stringValue, value: String(value)))
    }

    mutating func encode(_ value: Int64, forKey key: Key) throws {
        encoder.fields.append(MultipartField(name: key.stringValue, value: String(value)))
    }

    mutating func encode(_ value: UInt, forKey key: Key) throws {
        encoder.fields.append(MultipartField(name: key.stringValue, value: String(value)))
    }

    mutating func encode(_ value: UInt8, forKey key: Key) throws {
        encoder.fields.append(MultipartField(name: key.stringValue, value: String(value)))
    }

    mutating func encode(_ value: UInt16, forKey key: Key) throws {
        encoder.fields.append(MultipartField(name: key.stringValue, value: String(value)))
    }

    mutating func encode(_ value: UInt32, forKey key: Key) throws {
        encoder.fields.append(MultipartField(name: key.stringValue, value: String(value)))
    }

    mutating func encode(_ value: UInt64, forKey key: Key) throws {
        encoder.fields.append(MultipartField(name: key.stringValue, value: String(value)))
    }

    mutating func encode<T>(_ value: T, forKey key: Key) throws where T: Encodable {
        // Handle arrays
        if let array = value as? [Any] {
            try encodeArray(array, forKey: key)
            return
        }

        // For other complex types, encode them as nested JSON
        // (This is a simplification - in practice you might want more sophisticated handling)
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(value)
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            encoder.fields.append(MultipartField(name: key.stringValue, value: jsonString))
        }
    }

    private mutating func encodeArray(_ array: [Any], forKey key: Key) throws {
        let fieldName: String
        switch arrayStrategy {
        case .accumulateValues:
            fieldName = key.stringValue
        case .brackets:
            fieldName = "\(key.stringValue)[]"
        }

        for element in array {
            let stringValue: String
            if let stringElement = element as? String {
                stringValue = stringElement
            } else if let intElement = element as? Int {
                stringValue = String(intElement)
            } else if let boolElement = element as? Bool {
                stringValue = boolElement ? "true" : "false"
            } else {
                // For complex types, use JSON encoding
                let jsonEncoder = JSONEncoder()
                if let encodable = element as? Encodable,
                   let jsonData = try? jsonEncoder.encode(encodable),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    stringValue = jsonString
                } else {
                    stringValue = String(describing: element)
                }
            }

            encoder.fields.append(MultipartField(name: fieldName, value: stringValue))
        }
    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        fatalError("Nested containers not yet implemented for multipart encoding")
    }

    mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        fatalError("Nested unkeyed containers not yet implemented for multipart encoding")
    }

    mutating func superEncoder() -> Encoder {
        encoder
    }

    mutating func superEncoder(forKey key: Key) -> Encoder {
        encoder
    }
}

private struct MultipartSingleValueEncodingContainer: SingleValueEncodingContainer {
    let encoder: MultipartFieldEncoder
    var codingPath: [CodingKey]

    mutating func encodeNil() throws {
        // Skip
    }

    mutating func encode(_ value: Bool) throws {
        encoder.fields.append(MultipartField(name: "", value: value ? "true" : "false"))
    }

    mutating func encode(_ value: String) throws {
        encoder.fields.append(MultipartField(name: "", value: value))
    }

    mutating func encode(_ value: Double) throws {
        encoder.fields.append(MultipartField(name: "", value: String(value)))
    }

    mutating func encode(_ value: Float) throws {
        encoder.fields.append(MultipartField(name: "", value: String(value)))
    }

    mutating func encode(_ value: Int) throws {
        encoder.fields.append(MultipartField(name: "", value: String(value)))
    }

    mutating func encode(_ value: Int8) throws {
        encoder.fields.append(MultipartField(name: "", value: String(value)))
    }

    mutating func encode(_ value: Int16) throws {
        encoder.fields.append(MultipartField(name: "", value: String(value)))
    }

    mutating func encode(_ value: Int32) throws {
        encoder.fields.append(MultipartField(name: "", value: String(value)))
    }

    mutating func encode(_ value: Int64) throws {
        encoder.fields.append(MultipartField(name: "", value: String(value)))
    }

    mutating func encode(_ value: UInt) throws {
        encoder.fields.append(MultipartField(name: "", value: String(value)))
    }

    mutating func encode(_ value: UInt8) throws {
        encoder.fields.append(MultipartField(name: "", value: String(value)))
    }

    mutating func encode(_ value: UInt16) throws {
        encoder.fields.append(MultipartField(name: "", value: String(value)))
    }

    mutating func encode(_ value: UInt32) throws {
        encoder.fields.append(MultipartField(name: "", value: String(value)))
    }

    mutating func encode(_ value: UInt64) throws {
        encoder.fields.append(MultipartField(name: "", value: String(value)))
    }

    mutating func encode<T>(_ value: T) throws where T: Encodable {
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(value)
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            encoder.fields.append(MultipartField(name: "", value: jsonString))
        }
    }
}
