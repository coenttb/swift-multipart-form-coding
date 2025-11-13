import Testing
import Foundation
@testable import MultipartFormCoding

@Suite("ImageType JPEG Validation")
struct ImageTypeJPEGTests {

    func createValidJPEG() -> Data {
        var data = Data([0xFF, 0xD8, 0xFF])
        data.append(Data(repeating: 0x00, count: 100))
        return data
    }

    @Test("Validates correct JPEG magic numbers")
    func testValidJPEG() throws {
        let upload = try Multipart.FileUpload(
            fieldName: "photo",
            filename: "test.jpg",
            fileType: .image(.jpeg)
        )

        try upload.validate(createValidJPEG())
    }

    @Test("Rejects invalid JPEG magic numbers")
    func testInvalidJPEG() throws {
        let upload = try Multipart.FileUpload(
            fieldName: "photo",
            filename: "test.jpg",
            fileType: .image(.jpeg)
        )

        let invalidData = Data([0x00, 0x00, 0x00])

        #expect(throws: Multipart.FileUpload.MultipartError.self) {
            try upload.validate(invalidData)
        }
    }
}

@Suite("ImageType PNG Validation")
struct ImageTypePNGTests {

    func createValidPNG() -> Data {
        var data = Data([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
        data.append(Data(repeating: 0x00, count: 100))
        return data
    }

    @Test("Validates correct PNG signature")
    func testValidPNG() throws {
        let upload = try Multipart.FileUpload(
            fieldName: "image",
            filename: "test.png",
            fileType: .image(.png)
        )

        try upload.validate(createValidPNG())
    }

    @Test("Rejects invalid PNG signature")
    func testInvalidPNG() throws {
        let upload = try Multipart.FileUpload(
            fieldName: "image",
            filename: "test.png",
            fileType: .image(.png)
        )

        let invalidData = Data(repeating: 0x00, count: 8)

        #expect(throws: Multipart.FileUpload.MultipartError.self) {
            try upload.validate(invalidData)
        }
    }
}

@Suite("ImageType GIF Validation")
struct ImageTypeGIFTests {

    @Test("Validates GIF89a signature")
    func testValidGIF89a() throws {
        let upload = try Multipart.FileUpload(
            fieldName: "animation",
            filename: "test.gif",
            fileType: .image(.gif)
        )

        var validGIF = Data("GIF89a".utf8)
        validGIF.append(Data(repeating: 0x00, count: 100))

        try upload.validate(validGIF)
    }

    @Test("Validates GIF87a signature")
    func testValidGIF87a() throws {
        let upload = try Multipart.FileUpload(
            fieldName: "animation",
            filename: "test.gif",
            fileType: .image(.gif)
        )

        var validGIF = Data("GIF87a".utf8)
        validGIF.append(Data(repeating: 0x00, count: 100))

        try upload.validate(validGIF)
    }

    @Test("Rejects invalid GIF signature")
    func testInvalidGIF() throws {
        let upload = try Multipart.FileUpload(
            fieldName: "animation",
            filename: "test.gif",
            fileType: .image(.gif)
        )

        let invalidData = Data("NOTGIF".utf8)

        #expect(throws: Multipart.FileUpload.MultipartError.self) {
            try upload.validate(invalidData)
        }
    }
}

@Suite("ImageType WebP Validation")
struct ImageTypeWebPTests {

    func createValidWebP() -> Data {
        var data = Data("RIFF".utf8)
        data.append(Data([0x00, 0x00, 0x00, 0x00]))  // Size placeholder
        data.append(Data("WEBP".utf8))
        data.append(Data(repeating: 0x00, count: 100))
        return data
    }

    @Test("Validates correct WebP structure")
    func testValidWebP() throws {
        let upload = try Multipart.FileUpload(
            fieldName: "image",
            filename: "test.webp",
            fileType: .image(.webp)
        )

        try upload.validate(createValidWebP())
    }

    @Test("Rejects WebP without RIFF header")
    func testInvalidWebPNoRIFF() throws {
        let upload = try Multipart.FileUpload(
            fieldName: "image",
            filename: "test.webp",
            fileType: .image(.webp)
        )

        var invalidData = Data("XXXX".utf8)
        invalidData.append(Data([0x00, 0x00, 0x00, 0x00]))
        invalidData.append(Data("WEBP".utf8))

        #expect(throws: Multipart.FileUpload.MultipartError.self) {
            try upload.validate(invalidData)
        }
    }

    @Test("Rejects WebP without WEBP identifier")
    func testInvalidWebPNoWEBP() throws {
        let upload = try Multipart.FileUpload(
            fieldName: "image",
            filename: "test.webp",
            fileType: .image(.webp)
        )

        var invalidData = Data("RIFF".utf8)
        invalidData.append(Data([0x00, 0x00, 0x00, 0x00]))
        invalidData.append(Data("XXXX".utf8))

        #expect(throws: Multipart.FileUpload.MultipartError.self) {
            try upload.validate(invalidData)
        }
    }
}

@Suite("ImageType TIFF Validation")
struct ImageTypeTIFFTests {

    @Test("Validates Intel byte order TIFF")
    func testValidTIFFIntel() throws {
        let upload = try Multipart.FileUpload(
            fieldName: "scan",
            filename: "test.tiff",
            fileType: .image(.tiff)
        )

        var validTIFF = Data([0x49, 0x49, 0x2A, 0x00])  // Intel
        validTIFF.append(Data(repeating: 0x00, count: 100))

        try upload.validate(validTIFF)
    }

    @Test("Validates Motorola byte order TIFF")
    func testValidTIFFMotorola() throws {
        let upload = try Multipart.FileUpload(
            fieldName: "scan",
            filename: "test.tiff",
            fileType: .image(.tiff)
        )

        var validTIFF = Data([0x4D, 0x4D, 0x00, 0x2A])  // Motorola
        validTIFF.append(Data(repeating: 0x00, count: 100))

        try upload.validate(validTIFF)
    }

    @Test("Rejects invalid TIFF magic numbers")
    func testInvalidTIFF() throws {
        let upload = try Multipart.FileUpload(
            fieldName: "scan",
            filename: "test.tiff",
            fileType: .image(.tiff)
        )

        let invalidData = Data([0x00, 0x00, 0x00, 0x00])

        #expect(throws: Multipart.FileUpload.MultipartError.self) {
            try upload.validate(invalidData)
        }
    }
}

@Suite("ImageType BMP Validation")
struct ImageTypeBMPTests {

    func createValidBMP() -> Data {
        var data = Data([0x42, 0x4D])  // "BM"
        data.append(Data(repeating: 0x00, count: 100))
        return data
    }

    @Test("Validates correct BMP signature")
    func testValidBMP() throws {
        let upload = try Multipart.FileUpload(
            fieldName: "bitmap",
            filename: "test.bmp",
            fileType: .image(.bmp)
        )

        try upload.validate(createValidBMP())
    }

    @Test("Rejects invalid BMP signature")
    func testInvalidBMP() throws {
        let upload = try Multipart.FileUpload(
            fieldName: "bitmap",
            filename: "test.bmp",
            fileType: .image(.bmp)
        )

        let invalidData = Data([0x00, 0x00])

        #expect(throws: Multipart.FileUpload.MultipartError.self) {
            try upload.validate(invalidData)
        }
    }
}

@Suite("ImageType HEIC Validation")
struct ImageTypeHEICTests {

    func createValidHEIC() -> Data {
        var data = Data(repeating: 0x00, count: 4)  // Size bytes
        data.append(Data("ftyp".utf8))
        data.append(Data("heic".utf8))
        data.append(Data(repeating: 0x00, count: 100))
        return data
    }

    @Test("Validates correct HEIC container structure")
    func testValidHEIC() throws {
        let upload = try Multipart.FileUpload(
            fieldName: "photo",
            filename: "test.heic",
            fileType: .image(.heic)
        )

        try upload.validate(createValidHEIC())
    }

    @Test("Rejects HEIC without ftyp box")
    func testInvalidHEICNoFtyp() throws {
        let upload = try Multipart.FileUpload(
            fieldName: "photo",
            filename: "test.heic",
            fileType: .image(.heic)
        )

        var invalidData = Data(repeating: 0x00, count: 4)
        invalidData.append(Data("XXXX".utf8))
        invalidData.append(Data("heic".utf8))

        #expect(throws: Multipart.FileUpload.MultipartError.self) {
            try upload.validate(invalidData)
        }
    }

    @Test("Rejects HEIC without heic brand")
    func testInvalidHEICNoBrand() throws {
        let upload = try Multipart.FileUpload(
            fieldName: "photo",
            filename: "test.heic",
            fileType: .image(.heic)
        )

        var invalidData = Data(repeating: 0x00, count: 4)
        invalidData.append(Data("ftyp".utf8))
        invalidData.append(Data("XXXX".utf8))

        #expect(throws: Multipart.FileUpload.MultipartError.self) {
            try upload.validate(invalidData)
        }
    }

    @Test("Rejects HEIC data that is too short")
    func testInvalidHEICTooShort() throws {
        let upload = try Multipart.FileUpload(
            fieldName: "photo",
            filename: "test.heic",
            fileType: .image(.heic)
        )

        let invalidData = Data(repeating: 0x00, count: 10)  // Less than 12 bytes

        #expect(throws: Multipart.FileUpload.MultipartError.self) {
            try upload.validate(invalidData)
        }
    }
}

@Suite("ImageType AVIF Validation")
struct ImageTypeAVIFTests {

    func createValidAVIF() -> Data {
        var data = Data(repeating: 0x00, count: 4)  // Size bytes
        data.append(Data("ftyp".utf8))
        data.append(Data("avif".utf8))
        data.append(Data(repeating: 0x00, count: 100))
        return data
    }

    @Test("Validates correct AVIF container structure")
    func testValidAVIF() throws {
        let upload = try Multipart.FileUpload(
            fieldName: "photo",
            filename: "test.avif",
            fileType: .image(.avif)
        )

        try upload.validate(createValidAVIF())
    }

    @Test("Rejects AVIF without ftyp box")
    func testInvalidAVIFNoFtyp() throws {
        let upload = try Multipart.FileUpload(
            fieldName: "photo",
            filename: "test.avif",
            fileType: .image(.avif)
        )

        var invalidData = Data(repeating: 0x00, count: 4)
        invalidData.append(Data("XXXX".utf8))
        invalidData.append(Data("avif".utf8))

        #expect(throws: Multipart.FileUpload.MultipartError.self) {
            try upload.validate(invalidData)
        }
    }

    @Test("Rejects AVIF without avif brand")
    func testInvalidAVIFNoBrand() throws {
        let upload = try Multipart.FileUpload(
            fieldName: "photo",
            filename: "test.avif",
            fileType: .image(.avif)
        )

        var invalidData = Data(repeating: 0x00, count: 4)
        invalidData.append(Data("ftyp".utf8))
        invalidData.append(Data("XXXX".utf8))

        #expect(throws: Multipart.FileUpload.MultipartError.self) {
            try upload.validate(invalidData)
        }
    }

    @Test("Rejects AVIF data that is too short")
    func testInvalidAVIFTooShort() throws {
        let upload = try Multipart.FileUpload(
            fieldName: "photo",
            filename: "test.avif",
            fileType: .image(.avif)
        )

        let invalidData = Data(repeating: 0x00, count: 10)  // Less than 12 bytes

        #expect(throws: Multipart.FileUpload.MultipartError.self) {
            try upload.validate(invalidData)
        }
    }
}
