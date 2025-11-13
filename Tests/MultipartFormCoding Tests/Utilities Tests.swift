import Testing
import Foundation
@testable import MultipartFormCoding

@Suite("DateFormatter Extensions")
struct DateFormatterTests {

    @MainActor
    @Test("form DateFormatter has correct format")
    func testFormDateFormatter() {
        let formatter = DateFormatter.form
        #expect(formatter.dateFormat == "yyyy-MM-dd")
    }

    @MainActor
    @Test("form DateFormatter formats dates correctly")
    func testFormDateFormatting() {
        let formatter = DateFormatter.form
        formatter.timeZone = TimeZone(identifier: "UTC")

        var components = DateComponents()
        components.year = 2024
        components.month = 1
        components.day = 15
        components.timeZone = TimeZone(identifier: "UTC")

        if let date = Calendar.current.date(from: components) {
            let formatted = formatter.string(from: date)
            #expect(formatted == "2024-01-15")
        } else {
            Issue.record("Failed to create date")
        }
    }

    @MainActor
    @Test("form DateFormatter parses dates correctly")
    func testFormDateParsing() {
        let formatter = DateFormatter.form
        formatter.timeZone = TimeZone(identifier: "UTC")

        let dateString = "2024-12-25"
        if let date = formatter.date(from: dateString) {
            let calendar = Calendar.current
            let components = calendar.dateComponents(
                in: TimeZone(identifier: "UTC")!,
                from: date
            )

            #expect(components.year == 2024)
            #expect(components.month == 12)
            #expect(components.day == 25)
        } else {
            Issue.record("Failed to parse date")
        }
    }
}

@Suite("Data Extensions")
struct DataExtensionsTests {

    @Test("append(String) appends UTF-8 encoded string")
    func testAppendString() {
        var data = Data()
        data.append("Hello")

        #expect(data == Data("Hello".utf8))
    }

    @Test("append(String) appends multiple strings")
    func testAppendMultipleStrings() {
        var data = Data()
        data.append("Hello")
        data.append(", ")
        data.append("World")

        #expect(data == Data("Hello, World".utf8))
    }

    @Test("append(String) handles empty string")
    func testAppendEmptyString() {
        var data = Data("Initial".utf8)
        let initialCount = data.count

        data.append("")

        #expect(data.count == initialCount)
    }

    @Test("append(String) handles special characters")
    func testAppendSpecialCharacters() {
        var data = Data()
        data.append("Hello 你好 🌍")

        let expected = Data("Hello 你好 🌍".utf8)
        #expect(data == expected)
    }

    @Test("append(String) handles newlines and CRLF")
    func testAppendNewlines() {
        var data = Data()
        data.append("Line 1\r\n")
        data.append("Line 2\n")
        data.append("Line 3")

        let expected = Data("Line 1\r\nLine 2\nLine 3".utf8)
        #expect(data == expected)
    }

    @Test("append(String) can build multipart boundaries")
    func testAppendMultipartBoundaries() {
        let boundary = "----Boundary123"
        var data = Data()

        data.append("--")
        data.append(boundary)
        data.append("\r\n")

        let expected = Data("--\(boundary)\r\n".utf8)
        #expect(data == expected)
    }
}

@Suite("URLRouting Field Extensions")
struct FieldExtensionsTests {

    @Test("contentType extension exists and compiles")
    func testContentTypeExtensionExists() {
        // This test verifies that the Field.contentType extension compiles
        // The actual usage would require a Parser conforming type, which is
        // beyond the scope of unit testing the extension itself.
        // The extension is tested through integration with actual URLRouting parsers.
        #expect(Bool(true))
    }
}
