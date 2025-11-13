import Testing
import Foundation
@testable import MultipartFormCoding
@testable import MultipartFormCodingURLRouting

@Suite("Multipart.Conversion Tests")
struct MultipartConversionTests {

    // MARK: - Test Models

    struct SimpleRequest: Codable, Equatable {
        let name: String
        let email: String
        let age: Int
    }

    struct RequestWithOptionals: Codable, Equatable {
        let name: String
        let email: String?
        let phone: String?
    }

    struct RequestWithArrays: Codable, Equatable {
        let name: String
        let tags: [String]
    }

    struct RequestWithBool: Codable, Equatable {
        let name: String
        let subscribed: Bool
        let verified: Bool
    }

    // MARK: - Basic Encoding Tests

    @Test("Encodes simple struct to multipart format")
    func testSimpleEncoding() throws {
        let request = SimpleRequest(name: "John Doe", email: "john@example.com", age: 30)
        let conversion = Multipart.Conversion(SimpleRequest.self)

        let data = try conversion.unapply(request)

        // Verify we got valid multipart data (non-empty, contains boundary)
        #expect(!data.isEmpty)
        let string = String(data: data, encoding: .utf8)!
        #expect(string.contains(conversion.boundary))
    }

    // MARK: - Optional Field Tests

    @Test("Handles optional fields correctly")
    func testOptionalFields() throws {
        // With all optionals present
        let requestWithOptionals = RequestWithOptionals(
            name: "John",
            email: "john@example.com",
            phone: "123-456-7890"
        )
        let conversion1 = Multipart.Conversion(RequestWithOptionals.self)
        let data1 = try conversion1.unapply(requestWithOptionals)
        let string1 = String(data: data1, encoding: .utf8)!

        #expect(string1.contains("name=\"email\""))
        #expect(string1.contains("john@example.com"))
        #expect(string1.contains("name=\"phone\""))
        #expect(string1.contains("123-456-7890"))

        // With optionals nil
        let requestWithoutOptionals = RequestWithOptionals(
            name: "Jane",
            email: nil,
            phone: nil
        )
        let conversion2 = Multipart.Conversion(RequestWithOptionals.self)
        let data2 = try conversion2.unapply(requestWithoutOptionals)
        let string2 = String(data: data2, encoding: .utf8)!

        // Should not contain nil fields
        #expect(!string2.contains("name=\"email\""))
        #expect(!string2.contains("name=\"phone\""))
        #expect(string2.contains("name=\"name\""))
        #expect(string2.contains("Jane"))
    }

    // MARK: - Array Encoding Strategy Tests

    @Test("Array encoding with accumulateValues strategy")
    func testAccumulateValuesStrategy() throws {
        let request = RequestWithArrays(name: "Project", tags: ["swift", "ios", "server"])
        let conversion = Multipart.Conversion(
            RequestWithArrays.self,
            arrayEncodingStrategy: .accumulateValues
        )

        let data = try conversion.unapply(request)
        let string = String(data: data, encoding: .utf8)!

        // Should repeat field name for each array element
        let tagMatches = string.components(separatedBy: "name=\"tags\"").count - 1
        #expect(tagMatches == 3)  // Three occurrences of name="tags"

        // Verify all values present
        #expect(string.contains("swift"))
        #expect(string.contains("ios"))
        #expect(string.contains("server"))

        // Should NOT use brackets
        #expect(!string.contains("tags[]"))
    }

    @Test("Array encoding with brackets strategy")
    func testBracketsStrategy() throws {
        let request = RequestWithArrays(name: "Project", tags: ["swift", "ios", "server"])
        let conversion = Multipart.Conversion(
            RequestWithArrays.self,
            arrayEncodingStrategy: .brackets
        )

        let data = try conversion.unapply(request)
        let string = String(data: data, encoding: .utf8)!

        // Should use brackets notation
        let bracketMatches = string.components(separatedBy: "name=\"tags[]\"").count - 1
        #expect(bracketMatches == 3)  // Three occurrences of name="tags[]"

        // Verify all values present
        #expect(string.contains("swift"))
        #expect(string.contains("ios"))
        #expect(string.contains("server"))
    }

    @Test("Empty array handling")
    func testEmptyArray() throws {
        let request = RequestWithArrays(name: "Project", tags: [])
        let conversion = Multipart.Conversion(RequestWithArrays.self)

        let data = try conversion.unapply(request)
        let string = String(data: data, encoding: .utf8)!

        // Should still contain name field
        #expect(string.contains("name=\"name\""))
        #expect(string.contains("Project"))

        // Empty array should not add any tags fields
        #expect(!string.contains("name=\"tags\""))
    }

    // MARK: - Boolean Encoding Tests

    @Test("Boolean values encode as true/false")
    func testBooleanEncoding() throws {
        let request = RequestWithBool(name: "User", subscribed: true, verified: false)
        let conversion = Multipart.Conversion(RequestWithBool.self)

        let data = try conversion.unapply(request)
        let string = String(data: data, encoding: .utf8)!

        // Verify boolean string representation
        #expect(string.contains("true"))
        #expect(string.contains("false"))
    }

    // MARK: - Boundary Tests

    @Test("Each conversion generates unique boundary")
    func testUniqueBoundaries() {
        let conversion1 = Multipart.Conversion(SimpleRequest.self)
        let conversion2 = Multipart.Conversion(SimpleRequest.self)

        // Boundaries should be unique
        #expect(conversion1.boundary != conversion2.boundary)
    }

    @Test("Content-Type header includes boundary")
    func testContentTypeHeader() {
        let conversion = Multipart.Conversion(SimpleRequest.self)
        let contentType = conversion.contentType

        #expect(contentType.starts(with: "multipart/form-data; boundary="))
        #expect(contentType.contains(conversion.boundary))
    }

    // MARK: - Mailgun-style Request Tests

    @Test("Mailgun-style member update request")
    func testMailgunStyleRequest() throws {
        struct MemberUpdateRequest: Codable {
            let name: String
            let address: String
            let subscribed: Bool
            let vars: [String: String]?
        }

        let request = MemberUpdateRequest(
            name: "Updated Name",
            address: "user@example.com",
            subscribed: true,
            vars: nil
        )

        let conversion = Multipart.Conversion(
            MemberUpdateRequest.self,
            arrayEncodingStrategy: .accumulateValues
        )

        let data = try conversion.unapply(request)

        // Verify we got valid multipart data
        #expect(!data.isEmpty)
        let string = String(data: data, encoding: .utf8)!
        #expect(string.contains(conversion.boundary))
    }
}
