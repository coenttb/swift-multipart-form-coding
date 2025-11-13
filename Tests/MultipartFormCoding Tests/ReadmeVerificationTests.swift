import Testing
import Foundation
@testable import MultipartFormCoding

@Suite("README Verification")
struct ReadmeVerificationTests {

    @Test("Example from README: Basic File Upload")
    func basicFileUpload() throws {
        // Create file upload with validation
        let imageUpload = try Multipart.FileUpload(
            fieldName: "avatar",
            filename: "profile.jpg",
            fileType: .image(.jpeg),
            maxSize: 5 * 1024 * 1024  // 5MB limit
        )

        // Verify properties
        #expect(imageUpload.fieldName == "avatar")
        #expect(imageUpload.filename == "profile.jpg")
        #expect(imageUpload.maxSize == 5 * 1024 * 1024)

        // Create minimal valid JPEG data (FFD8FF magic number)
        let jpegMagicNumber: [UInt8] = [0xFF, 0xD8, 0xFF]
        var imageData = Data(jpegMagicNumber)
        // Add some minimal content to avoid empty data error
        imageData.append(contentsOf: [0xE0, 0x00, 0x10])

        // Validate file data
        try imageUpload.validate(imageData)
    }

    @Test("Example from README: Supported File Types")
    func supportedFileTypes() throws {
        // Images
        let jpeg = try Multipart.FileUpload(
            fieldName: "photo",
            filename: "photo.jpg",
            fileType: .image(.jpeg)
        )
        #expect(jpeg.fileType.contentType.type == "image")

        let png = try Multipart.FileUpload(
            fieldName: "photo",
            filename: "photo.png",
            fileType: .image(.png)
        )
        #expect(png.fileType.contentType.subtype == "png")

        // Documents
        let pdf = try Multipart.FileUpload(
            fieldName: "document",
            filename: "file.pdf",
            fileType: .pdf
        )
        #expect(pdf.fileType.contentType.subtype == "pdf")

        let csv = try Multipart.FileUpload(
            fieldName: "data",
            filename: "data.csv",
            fileType: .csv
        )
        #expect(csv.fileType.contentType.subtype == "csv")
    }
}
