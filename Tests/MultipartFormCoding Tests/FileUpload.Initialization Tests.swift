import Testing
import Foundation
@testable import MultipartFormCoding

@Suite("FileUpload Initialization")
struct FileUploadInitializationTests {

    @Test("Initializes with valid parameters")
    func testValidInitialization() throws {
        let upload = try Multipart.FileUpload(
            fieldName: "photo",
            filename: "test.jpg",
            fileType: .image(.jpeg)
        )

        #expect(!upload.boundary.isEmpty)
        #expect(upload.contentType.starts(with: "multipart/form-data; boundary="))
    }

    @Test("Generates unique boundaries for each instance")
    func testUniqueBoundaries() throws {
        let upload1 = try Multipart.FileUpload(
            fieldName: "file1",
            filename: "test1.jpg",
            fileType: .image(.jpeg)
        )

        let upload2 = try Multipart.FileUpload(
            fieldName: "file2",
            filename: "test2.jpg",
            fileType: .image(.jpeg)
        )

        #expect(upload1.boundary != upload2.boundary)
    }

    @Test("Initializes with custom max size")
    func testCustomMaxSize() throws {
        let customSize = 1024 * 1024  // 1MB
        let upload = try Multipart.FileUpload(
            fieldName: "thumbnail",
            filename: "thumb.jpg",
            fileType: .image(.jpeg),
            maxSize: customSize
        )

        #expect(!upload.boundary.isEmpty)
    }

    @Test("Content-Type header includes boundary")
    func testContentTypeHeader() throws {
        let upload = try Multipart.FileUpload(
            fieldName: "file",
            filename: "test.jpg",
            fileType: .image(.jpeg)
        )

        #expect(upload.contentType.starts(with: "multipart/form-data; boundary="))
        #expect(upload.contentType.contains(upload.boundary))
    }
}

@Suite("FileUpload Validation Errors")
struct FileUploadValidationErrorTests {

    @Test("Throws emptyFieldName when field name is empty")
    func testEmptyFieldName() {
        #expect(throws: Multipart.FileUpload.MultipartError.emptyFieldName) {
            _ = try Multipart.FileUpload(
                fieldName: "",
                filename: "test.jpg",
                fileType: .pdf
            )
        }
    }

    @Test("Throws emptyFilename when filename is empty")
    func testEmptyFilename() {
        #expect(throws: Multipart.FileUpload.MultipartError.emptyFilename) {
            _ = try Multipart.FileUpload(
                fieldName: "file",
                filename: "",
                fileType: .pdf
            )
        }
    }

    @Test("Throws invalidFilename for forward slash")
    func testFilenameWithForwardSlash() {
        do {
            _ = try Multipart.FileUpload(
                fieldName: "file",
                filename: "path/to/test.jpg",
                fileType: .pdf
            )
            Issue.record("Expected invalidFilename error")
        } catch let error as Multipart.FileUpload.MultipartError {
            if case .invalidFilename(let filename) = error {
                #expect(filename == "path/to/test.jpg")
            } else {
                Issue.record("Expected invalidFilename error, got \(error)")
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    @Test("Throws invalidFilename for backslash")
    func testFilenameWithBackslash() {
        do {
            _ = try Multipart.FileUpload(
                fieldName: "file",
                filename: "path\\test.jpg",
                fileType: .pdf
            )
            Issue.record("Expected invalidFilename error")
        } catch let error as Multipart.FileUpload.MultipartError {
            if case .invalidFilename(let filename) = error {
                #expect(filename == "path\\test.jpg")
            } else {
                Issue.record("Expected invalidFilename error, got \(error)")
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    @Test("Throws invalidMaxSize for zero")
    func testZeroMaxSize() {
        do {
            _ = try Multipart.FileUpload(
                fieldName: "file",
                filename: "test.jpg",
                fileType: .pdf,
                maxSize: 0
            )
            Issue.record("Expected invalidMaxSize error")
        } catch let error as Multipart.FileUpload.MultipartError {
            if case .invalidMaxSize(let size) = error {
                #expect(size == 0)
            } else {
                Issue.record("Expected invalidMaxSize error, got \(error)")
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    @Test("Throws invalidMaxSize for negative value")
    func testNegativeMaxSize() {
        do {
            _ = try Multipart.FileUpload(
                fieldName: "file",
                filename: "test.jpg",
                fileType: .pdf,
                maxSize: -100
            )
            Issue.record("Expected invalidMaxSize error")
        } catch let error as Multipart.FileUpload.MultipartError {
            if case .invalidMaxSize(let size) = error {
                #expect(size == -100)
            } else {
                Issue.record("Expected invalidMaxSize error, got \(error)")
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    @Test("Throws maxSizeExceedsLimit for excessive size")
    func testExcessiveMaxSize() {
        let excessiveSize = 2 * 1024 * 1024 * 1024  // 2GB

        do {
            _ = try Multipart.FileUpload(
                fieldName: "file",
                filename: "test.jpg",
                fileType: .pdf,
                maxSize: excessiveSize
            )
            Issue.record("Expected maxSizeExceedsLimit error")
        } catch let error as Multipart.FileUpload.MultipartError {
            if case .maxSizeExceedsLimit(let size) = error {
                #expect(size == excessiveSize)
            } else {
                Issue.record("Expected maxSizeExceedsLimit error, got \(error)")
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    @Test("Accepts max size at 1GB limit")
    func testMaxSizeAtLimit() throws {
        let upload = try Multipart.FileUpload(
            fieldName: "file",
            filename: "test.jpg",
            fileType: .pdf,
            maxSize: 1024 * 1024 * 1024  // Exactly 1GB - should be valid
        )

        #expect(!upload.boundary.isEmpty)
    }
}
