#if URLRouting
import Testing
import Foundation
import URLRouting
import MultipartFormCoding

@Suite("Multipart.Conversion Integration Tests")
struct MultipartConversionIntegrationTests {

    struct TestRequest: Codable, Equatable {
        let name: String
        let subscribed: Bool
    }

    @Test("Multipart.Conversion exists and is accessible")
    func testConversionExists() {
        let conversion = Multipart.Conversion(TestRequest.self)
        #expect(!conversion.boundary.isEmpty)
        #expect(conversion.contentType.contains("multipart/form-data"))
    }

    @Test("Conversion.multipart() static method works")
    func testStaticMultipartMethod() throws {
        // Use explicit type to call static method on concrete type
        let conversion: Multipart.Conversion<TestRequest> = .multipart(TestRequest.self)
        let request = TestRequest(name: "John", subscribed: true)
        let data = try conversion.unapply(request)
        #expect(!data.isEmpty)
    }

    @Test("Generates valid multipart data")
    func testMultipartGeneration() throws {
        let conversion = Multipart.Conversion(TestRequest.self)
        let request = TestRequest(name: "Test User", subscribed: false)

        let data = try conversion.unapply(request)
        let string = String(data: data, encoding: .utf8)!

        #expect(string.contains(conversion.boundary))
        #expect(string.contains("Content-Disposition"))
        #expect(string.contains("name"))
        #expect(string.contains("Test User"))
    }

    @Test("Array encoding with accumulate values strategy")
    func testArrayEncodingAccumulateValues() throws {
        struct RequestWithArray: Codable {
            let tags: [String]
        }

        let conversion = Multipart.Conversion(
            RequestWithArray.self,
            arrayEncodingStrategy: .accumulateValues
        )
        let request = RequestWithArray(tags: ["swift", "ios"])
        let data = try conversion.unapply(request)
        let string = String(data: data, encoding: .utf8)!

        // Should repeat field name for each value
        let tagCount = string.components(separatedBy: "name=\"tags\"").count - 1
        #expect(tagCount == 2)
    }

    @Test("Array encoding with brackets strategy")
    func testArrayEncodingBrackets() throws {
        struct RequestWithArray: Codable {
            let tags: [String]
        }

        let conversion = Multipart.Conversion(
            RequestWithArray.self,
            arrayEncodingStrategy: .brackets
        )
        let request = RequestWithArray(tags: ["swift", "ios"])
        let data = try conversion.unapply(request)
        let string = String(data: data, encoding: .utf8)!

        // Should use brackets notation
        #expect(string.contains("name=\"tags[]\""))
    }
}
#endif
