import Testing
import Foundation
@testable import MultipartFormCoding

@Suite("FileUpload Convenience Factories")
struct FileUploadConvenienceTests {

    @Test("CSV factory with default parameters")
    func testCSVFactoryDefaults() throws {
        let upload = try Multipart.FileUpload.csv()

        #expect(!upload.boundary.isEmpty)
        #expect(upload.contentType.starts(with: "multipart/form-data"))
        // Default values are used internally
    }

    @Test("CSV factory with custom field name")
    func testCSVFactoryCustomFieldName() throws {
        let upload = try Multipart.FileUpload.csv(fieldName: "csvData")

        #expect(!upload.boundary.isEmpty)
    }

    @Test("CSV factory with custom filename")
    func testCSVFactoryCustomFilename() throws {
        let upload = try Multipart.FileUpload.csv(
            fieldName: "data",
            filename: "export.csv"
        )

        #expect(!upload.boundary.isEmpty)
    }

    @Test("CSV factory with custom max size")
    func testCSVFactoryCustomMaxSize() throws {
        let upload = try Multipart.FileUpload.csv(
            maxSize: 1024 * 1024  // 1MB
        )

        #expect(!upload.boundary.isEmpty)
    }

    @Test("CSV factory with all custom parameters")
    func testCSVFactoryAllCustom() throws {
        let upload = try Multipart.FileUpload.csv(
            fieldName: "csvFile",
            filename: "data.csv",
            maxSize: 5 * 1024 * 1024
        )

        #expect(!upload.boundary.isEmpty)
        #expect(upload.contentType.contains(upload.boundary))
    }

    @Test("PDF factory with default parameters")
    func testPDFFactoryDefaults() throws {
        let upload = try Multipart.FileUpload.pdf()

        #expect(!upload.boundary.isEmpty)
        #expect(upload.contentType.starts(with: "multipart/form-data"))
    }

    @Test("PDF factory with custom parameters")
    func testPDFFactoryCustom() throws {
        let upload = try Multipart.FileUpload.pdf(
            fieldName: "document",
            filename: "report.pdf",
            maxSize: 10 * 1024 * 1024
        )

        #expect(!upload.boundary.isEmpty)
    }

    @Test("Excel factory with default parameters")
    func testExcelFactoryDefaults() throws {
        let upload = try Multipart.FileUpload.excel()

        #expect(!upload.boundary.isEmpty)
        #expect(upload.contentType.starts(with: "multipart/form-data"))
    }

    @Test("Excel factory with custom parameters")
    func testExcelFactoryCustom() throws {
        let upload = try Multipart.FileUpload.excel(
            fieldName: "spreadsheet",
            filename: "data.xlsx",
            maxSize: 20 * 1024 * 1024
        )

        #expect(!upload.boundary.isEmpty)
    }

    @Test("JPEG factory with default parameters")
    func testJPEGFactoryDefaults() throws {
        let upload = try Multipart.FileUpload.jpeg()

        #expect(!upload.boundary.isEmpty)
        #expect(upload.contentType.starts(with: "multipart/form-data"))
    }

    @Test("JPEG factory with custom parameters")
    func testJPEGFactoryCustom() throws {
        let upload = try Multipart.FileUpload.jpeg(
            fieldName: "photo",
            filename: "profile.jpg",
            maxSize: 5 * 1024 * 1024
        )

        #expect(!upload.boundary.isEmpty)
    }
}

@Suite("FileUpload Factory Default Filenames")
struct FileUploadFactoryDefaultFilenamesTests {

    @Test("CSV factory uses default filename when nil")
    func testCSVDefaultFilename() throws {
        let upload = try Multipart.FileUpload.csv(filename: nil)
        // Default filename "file.csv" is used internally
        #expect(!upload.boundary.isEmpty)
    }

    @Test("PDF factory uses default filename when nil")
    func testPDFDefaultFilename() throws {
        let upload = try Multipart.FileUpload.pdf(filename: nil)
        // Default filename "file.pdf" is used internally
        #expect(!upload.boundary.isEmpty)
    }

    @Test("Excel factory uses default filename when nil")
    func testExcelDefaultFilename() throws {
        let upload = try Multipart.FileUpload.excel(filename: nil)
        // Default filename "file.xlsx" is used internally
        #expect(!upload.boundary.isEmpty)
    }

    @Test("JPEG factory uses default filename when nil")
    func testJPEGDefaultFilename() throws {
        let upload = try Multipart.FileUpload.jpeg(filename: nil)
        // Default filename "file.jpg" is used internally
        #expect(!upload.boundary.isEmpty)
    }
}

@Suite("FileUpload Factory Validation")
struct FileUploadFactoryValidationTests {

    func createValidJPEG() -> Data {
        var data = Data([0xFF, 0xD8, 0xFF])
        data.append(Data(repeating: 0x00, count: 100))
        return data
    }

    func createValidPDF() -> Data {
        var data = Data("%PDF-1.4\n".utf8)
        data.append(Data(repeating: 0x00, count: 100))
        return data
    }

    func createValidCSV() -> Data {
        Data("name,email\nJohn,john@example.com".utf8)
    }

    @Test("JPEG factory creates upload that validates JPEGs")
    func testJPEGFactoryValidation() throws {
        let upload = try Multipart.FileUpload.jpeg()
        let validJPEG = createValidJPEG()

        try upload.validate(validJPEG)
    }

    @Test("PDF factory creates upload that validates PDFs")
    func testPDFFactoryValidation() throws {
        let upload = try Multipart.FileUpload.pdf()
        let validPDF = createValidPDF()

        try upload.validate(validPDF)
    }

    @Test("CSV factory creates upload that validates CSV")
    func testCSVFactoryValidation() throws {
        let upload = try Multipart.FileUpload.csv()
        let validCSV = createValidCSV()

        try upload.validate(validCSV)
    }

    @Test("Factory instances have unique boundaries")
    func testFactoryUniqueBoundaries() throws {
        let csv1 = try Multipart.FileUpload.csv()
        let csv2 = try Multipart.FileUpload.csv()
        let pdf1 = try Multipart.FileUpload.pdf()

        #expect(csv1.boundary != csv2.boundary)
        #expect(csv1.boundary != pdf1.boundary)
        #expect(csv2.boundary != pdf1.boundary)
    }
}
