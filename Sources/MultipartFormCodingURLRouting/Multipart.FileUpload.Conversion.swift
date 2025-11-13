import Foundation
import MultipartFormCoding
import URLRouting
import RFC_2046
import RFC_7578

extension Multipart.FileUpload {
    public typealias Conversion = Multipart.FileUpload
}

extension Multipart.FileUpload.Conversion: URLRouting.Conversion {
    // MARK: - Conversion Protocol Implementation

    /// Validates and returns the input file data.
    ///
    /// This method performs comprehensive validation on the uploaded file data:
    /// - Checks that data is not empty
    /// - Verifies file size is within limits
    /// - Validates file content matches expected type using magic numbers
    ///
    /// - Parameter input: The raw file data to validate
    /// - Returns: The validated file data (unchanged)
    /// - Throws: ``MultipartError`` if validation fails
    ///
    /// ## Validation Process
    ///
    /// 1. **Empty check**: Ensures file contains data
    /// 2. **Size check**: Verifies file is within size limits
    /// 3. **Content validation**: Uses magic numbers to verify file type
    ///
    /// ```swift
    /// // Example usage in route handler
    /// let fileData = try fileUpload.apply(uploadedData)
    /// // fileData is now validated and safe to process
    /// ```
    public func apply(_ input: Foundation.Data) throws -> Foundation.Data {
        try validate(input)
        return input
    }

    /// Converts file data to multipart/form-data format.
    ///
    /// This method wraps the file data in proper RFC 7578-compliant multipart/form-data format,
    /// using the RFC 2046 Multipart and RFC 7578 FormData implementations.
    ///
    /// - Parameter data: The file data to wrap in multipart format
    /// - Returns: Complete multipart form data including boundaries and headers
    /// - Throws: ``MultipartError`` if validation or encoding fails
    ///
    /// ## Generated Format
    ///
    /// The output follows RFC 7578 multipart/form-data specification:
    /// ```
    /// --Boundary-<random>
    /// Content-Disposition: form-data; name="fieldName"; filename="file.ext"
    /// Content-Type: application/octet-stream
    ///
    /// <file data>
    /// --Boundary-<random>--
    /// ```
    public func unapply(_ data: Foundation.Data) throws -> Foundation.Data {
        // Step 1: Validate the file data
        try validate(data)

        // Step 2: Create RFC 7578 FormData.File
        let file = try RFC_7578.FormData.File(
            fieldName: fieldName,
            filename: filename,
            contentType: fileType.contentType,
            content: data
        )

        // Step 3: Build RFC 2046 multipart message using RFC 7578 formData
        let multipart = try RFC_2046.Multipart.formData(
            fields: [:],
            files: [file],
            boundary: boundary
        )

        // Step 4: Render to RFC-compliant format with CRLF line endings
        let rendered = multipart.render()

        // Step 5: Convert to Data
        guard let result = rendered.data(using: String.Encoding.utf8) else {
            throw MultipartError.encodingError
        }

        return result
    }
}
