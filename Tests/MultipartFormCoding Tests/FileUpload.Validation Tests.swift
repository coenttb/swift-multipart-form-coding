import Testing
import Foundation
@testable import MultipartFormCoding

@Suite("FileUpload Size Validation")
struct FileUploadSizeValidationTests {

    func createJPEGData() -> Data {
        var data = Data([0xFF, 0xD8, 0xFF])
        data.append(Data(repeating: 0x00, count: 1000))
        return data
    }

    @Test("Validates files within size limit")
    func testFileWithinSizeLimit() throws {
        let upload = try Multipart.FileUpload(
            fieldName: "photo",
            filename: "small.jpg",
            fileType: .image(.jpeg),
            maxSize: 10 * 1024 * 1024  // 10MB
        )

        let smallData = createJPEGData()
        try upload.validate(smallData)
    }

    @Test("Rejects files exceeding max size")
    func testFileTooLarge() throws {
        let upload = try Multipart.FileUpload(
            fieldName: "photo",
            filename: "huge.jpg",
            fileType: .image(.jpeg),
            maxSize: 100  // Very small limit
        )

        let largeData = createJPEGData()  // 1000+ bytes

        do {
            try upload.validate(largeData)
            Issue.record("Expected fileTooLarge error")
        } catch let error as Multipart.FileUpload.Error {
            if case .fileTooLarge(let size, let maxSize) = error {
                #expect(size > maxSize)
            } else {
                Issue.record("Expected fileTooLarge error, got \(error)")
            }
        }
    }

    @Test("Rejects empty data")
    func testEmptyData() throws {
        let upload = try Multipart.FileUpload(
            fieldName: "photo",
            filename: "test.jpg",
            fileType: .image(.jpeg)
        )

        let emptyData = Data()

        #expect(throws: Multipart.FileUpload.Error.emptyData) {
            try upload.validate(emptyData)
        }
    }
}

@Suite("FileUpload Error Descriptions")
struct FileUploadErrorDescriptionTests {

    @Test("FileTooLarge error includes sizes")
    func testFileTooLargeDescription() {
        let error = Multipart.FileUpload.Error.fileTooLarge(
            size: 1000,
            maxSize: 500
        )
        #expect(error.errorDescription?.contains("1000") == true)
        #expect(error.errorDescription?.contains("500") == true)
    }

    @Test("ContentMismatch error includes types")
    func testContentMismatchDescription() {
        let error = Multipart.FileUpload.Error.contentMismatch(
            expected: "image/jpeg",
            detected: "image/png"
        )
        #expect(error.errorDescription?.contains("image/jpeg") == true)
        #expect(error.errorDescription?.contains("image/png") == true)
    }

    @Test("EmptyData error has description")
    func testEmptyDataDescription() {
        let error = Multipart.FileUpload.Error.emptyData
        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.isEmpty == false)
    }

    @Test("EncodingError has description")
    func testEncodingErrorDescription() {
        let error = Multipart.FileUpload.Error.encodingError
        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.isEmpty == false)
    }

    @Test("InvalidContentType error includes type")
    func testInvalidContentTypeDescription() {
        let error = Multipart.FileUpload.Error.invalidContentType("bad/type")
        #expect(error.errorDescription?.contains("bad/type") == true)
    }

    @Test("MalformedBoundary error has description")
    func testMalformedBoundaryDescription() {
        let error = Multipart.FileUpload.Error.malformedBoundary
        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.isEmpty == false)
    }

    @Test("EmptyFieldName error has description")
    func testEmptyFieldNameDescription() {
        let error = Multipart.FileUpload.Error.emptyFieldName
        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.contains("Field name") == true)
    }

    @Test("EmptyFilename error has description")
    func testEmptyFilenameDescription() {
        let error = Multipart.FileUpload.Error.emptyFilename
        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.contains("Filename") == true)
    }

    @Test("InvalidFilename error includes filename")
    func testInvalidFilenameDescription() {
        let error = Multipart.FileUpload.Error.invalidFilename("path/to/file.jpg")
        #expect(error.errorDescription?.contains("path/to/file.jpg") == true)
        #expect(error.errorDescription?.contains("path separators") == true)
    }

    @Test("InvalidMaxSize error includes size")
    func testInvalidMaxSizeDescription() {
        let error = Multipart.FileUpload.Error.invalidMaxSize(0)
        #expect(error.errorDescription?.contains("0") == true)
        #expect(error.errorDescription?.contains("positive") == true)
    }

    @Test("MaxSizeExceedsLimit error includes size")
    func testMaxSizeExceedsLimitDescription() {
        let largeSize = 2 * 1024 * 1024 * 1024
        let error = Multipart.FileUpload.Error.maxSizeExceedsLimit(largeSize)
        #expect(error.errorDescription?.contains("1GB") == true)
    }
}
