import Foundation
import RFC_2045

// MARK: - Predefined File Types

extension Multipart.FileUpload.FileType {
    /// CSV (Comma-Separated Values) file type with UTF-8 validation.
    ///
    /// Validates that the uploaded data can be decoded as UTF-8 text,
    /// ensuring the file contains valid textual CSV data.
    ///
    /// - Content Type: `text/csv`
    /// - File Extension: `csv`
    /// - Validation: UTF-8 text encoding check
    public static let csv: Self = .init(
        contentType: RFC_2045.ContentType(type: "text", subtype: "csv"),
        fileExtension: "csv"
    ) { (data: Foundation.Data) in
        guard let _ = String(data: data, encoding: .utf8) else {
            throw Multipart.FileUpload.MultipartError.contentMismatch(
                expected: "text/csv",
                detected: nil
            )
        }
    }
    
    /// PDF (Portable Document Format) file type with magic number validation.
    ///
    /// Validates the PDF magic number signature ("%PDF") to ensure the uploaded
    /// file is a genuine PDF document and not a disguised malicious file.
    ///
    /// - Content Type: `application/pdf`
    /// - File Extension: `pdf`
    /// - Validation: Checks for "%PDF" magic number at file start
    public static let pdf: Self = .init(
        contentType: RFC_2045.ContentType(type: "application", subtype: "pdf"),
        fileExtension: "pdf"
    ) { (data: Foundation.Data) in
        guard data.prefix(4).elementsEqual("%PDF".data(using: .utf8)!) else {
            throw Multipart.FileUpload.MultipartError.contentMismatch(
                expected: "application/pdf",
                detected: nil
            )
        }
    }
    
    /// Microsoft Excel (.xlsx) file type.
    ///
    /// Supports modern Excel files in Office Open XML format.
    /// No content validation is performed.
    ///
    /// - Content Type: `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`
    /// - File Extension: `xlsx`
    /// - Note: Consider adding magic number validation for enhanced security
    public static let excel: Self = .init(
        contentType: RFC_2045.ContentType(
            type: "application",
            subtype: "vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        ),
        fileExtension: "xlsx"
    )
    
    /// JSON (JavaScript Object Notation) file type.
    ///
    /// Standard JSON file format without content validation.
    /// For validation, consider using a custom FileType with JSON parsing.
    ///
    /// - Content Type: `application/json`
    /// - File Extension: `json`
    public static let json: Self = .init(
        contentType: RFC_2045.ContentType(type: "application", subtype: "json"),
        fileExtension: "json"
    )
    
    /// Plain text file type.
    ///
    /// Generic text files without specific validation.
    /// Accepts any content as valid text.
    ///
    /// - Content Type: `text/plain`
    /// - File Extension: `txt`
    public static let text: Self = .init(
        contentType: RFC_2045.ContentType.textPlain,
        fileExtension: "txt"
    )
    
    /// Creates a FileType for image files with magic number validation.
    ///
    /// This function converts an ``ImageType`` to a ``FileType``, enabling
    /// the use of specialized image validation within the general file type system.
    ///
    /// - Parameter type: The specific image type with validation rules
    /// - Returns: A FileType configured for the specified image format
    ///
    /// ## Example
    ///
    /// ```swift
    /// let jpegFileType = Multipart.FileUpload.FileType.image(.jpeg)
    /// let upload = Multipart.FileUpload(
    ///     fieldName: "photo",
    ///     filename: "image.jpg",
    ///     fileType: jpegFileType
    /// )
    /// ```
    ///
    /// ## Security
    ///
    /// Image types include built-in magic number validation to prevent
    /// malicious files disguised as images from being uploaded.
    nonisolated
    public static func image(_ type: ImageType) -> Multipart.FileUpload.FileType
    {
        Multipart.FileUpload.FileType(
            contentType: type.contentType,
            fileExtension: type.fileExtension,
            validate: type.validate
        )
    }
    
    // MARK: - Office Documents
    
    /// Microsoft Word (.docx) file type.
    ///
    /// Modern Word documents in Office Open XML format.
    ///
    /// - Content Type: `application/vnd.openxmlformats-officedocument.wordprocessingml.document`
    /// - File Extension: `docx`
    public static let docx: Self = .init(
        contentType: RFC_2045.ContentType(
            type: "application",
            subtype: "vnd.openxmlformats-officedocument.wordprocessingml.document"
        ),
        fileExtension: "docx"
    )
    
    /// Legacy Microsoft Word (.doc) file type.
    ///
    /// Older Word document format.
    ///
    /// - Content Type: `application/msword`
    /// - File Extension: `doc`
    public static let doc: Self = .init(
        contentType: RFC_2045.ContentType(type: "application", subtype: "msword"),
        fileExtension: "doc"
    )
    
    // MARK: - Archive Files
    
    /// ZIP archive file type.
    ///
    /// Standard ZIP compressed archive format.
    ///
    /// - Content Type: `application/zip`
    /// - File Extension: `zip`
    public static let zip: Self = .init(
        contentType: RFC_2045.ContentType(type: "application", subtype: "zip"),
        fileExtension: "zip"
    )
    
    // MARK: - Audio Files
    
    /// MP3 audio file type.
    ///
    /// MPEG-1 Audio Layer III compressed audio format.
    ///
    /// - Content Type: `audio/mpeg`
    /// - File Extension: `mp3`
    public static let mp3: Self = .init(
        contentType: RFC_2045.ContentType(type: "audio", subtype: "mpeg"),
        fileExtension: "mp3"
    )
    
    /// WAV audio file type.
    ///
    /// Waveform Audio File Format for uncompressed audio.
    ///
    /// - Content Type: `audio/wav`
    /// - File Extension: `wav`
    public static let wav: Self = .init(
        contentType: RFC_2045.ContentType(type: "audio", subtype: "wav"),
        fileExtension: "wav"
    )
    
    // MARK: - Video Files
    
    /// MP4 video file type.
    ///
    /// MPEG-4 Part 14 multimedia container format.
    ///
    /// - Content Type: `video/mp4`
    /// - File Extension: `mp4`
    public static let mp4: Self = .init(
        contentType: RFC_2045.ContentType(type: "video", subtype: "mp4"),
        fileExtension: "mp4"
    )
    
    // MARK: - Database Files
    
    /// SQLite database file type.
    ///
    /// SQLite database format.
    ///
    /// - Content Type: `application/x-sqlite3`
    /// - File Extension: `sqlite`
    public static let sqlite: Self = .init(
        contentType: RFC_2045.ContentType(type: "application", subtype: "x-sqlite3"),
        fileExtension: "sqlite"
    )
    
    // MARK: - Programming Files
    
    /// Swift source code file type.
    ///
    /// Swift programming language source files.
    ///
    /// - Content Type: `text/x-swift`
    /// - File Extension: `swift`
    public static let swift: Self = .init(
        contentType: RFC_2045.ContentType(type: "text", subtype: "x-swift"),
        fileExtension: "swift"
    )
    
    /// JavaScript source code file type.
    ///
    /// JavaScript programming language files.
    ///
    /// - Content Type: `application/javascript`
    /// - File Extension: `js`
    public static let javascript: Self = .init(
        contentType: RFC_2045.ContentType(type: "application", subtype: "javascript"),
        fileExtension: "js"
    )
    
    // MARK: - Font Files
    
    /// TrueType Font file type.
    ///
    /// TrueType font format files.
    ///
    /// - Content Type: `font/ttf`
    /// - File Extension: `ttf`
    public static let ttf: Self = .init(
        contentType: RFC_2045.ContentType(type: "font", subtype: "ttf"),
        fileExtension: "ttf"
    )
    
    /// SVG (Scalable Vector Graphics) file type.
    ///
    /// XML-based vector image format.
    ///
    /// - Content Type: `image/svg+xml`
    /// - File Extension: `svg`
    public static let svg: Self = .init(
        contentType: RFC_2045.ContentType(type: "image", subtype: "svg+xml"),
        fileExtension: "svg"
    )
}
