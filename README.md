# swift-multipart-form-coding

A Swift package for handling `multipart/form-data` encoding with file upload support.

## Overview

`swift-multipart-form-coding` provides secure, type-safe file upload functionality with built-in validation, size limits, and content type checking according to RFC 7578 (multipart/form-data).

## Features

- ✅ **Secure File Uploads**: Magic number validation, size limits, content type checking
- ✅ **RFC Compliant**: Built on [RFC 2045](https://datatracker.ietf.org/doc/html/rfc2045) (MIME Content Types), [RFC 2046](https://datatracker.ietf.org/doc/html/rfc2046) (Multipart), and [RFC 7578](https://datatracker.ietf.org/doc/html/rfc7578) (Multipart/Form-Data)
- ✅ **URLRouting Integration**: First-class support for PointFree's URLRouting
- ✅ **Built-in File Types**: JPEG, PNG, GIF, WebP, PDF, CSV, JSON, and more
- ✅ **Swift 6.0**: Full strict concurrency support
- ✅ **Custom File Types**: Easy extensibility for custom file formats

## Installation

Add this package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/coenttb/swift-multipart-form-coding", from: "0.1.0")
]
```

Then add the product to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "MultipartFormCoding", package: "swift-multipart-form-coding")
    ]
)
```

## Quick Start

### Basic File Upload

```swift
import MultipartFormCoding

// Create file upload with validation
let imageUpload = try Multipart.FileUpload(
    fieldName: "avatar",
    filename: "profile.jpg",
    fileType: .image(.jpeg),
    maxSize: 5 * 1024 * 1024  // 5MB limit
)

// Validate file data
let imageData = Data(/* ... */)
try imageUpload.validate(imageData)

// FileUpload is used primarily with URLRouting
// For manual multipart encoding, see Multipart.Conversion below
```

### Supported File Types

**Images:**
- `.image(.jpeg)` - JPEG images with magic number validation
- `.image(.png)` - PNG images
- `.image(.gif)` - GIF images
- `.image(.webp)` - WebP images

**Documents:**
- `.pdf` - PDF documents
- `.csv` - CSV files
- `.json` - JSON files
- `.text` - Plain text files

**Custom Types:**
```swift
// ContentType is re-exported from RFC_2045
let xmlType = Multipart.FileUpload.FileType(
    contentType: ContentType(type: "application", subtype: "xml"),
    fileExtension: "xml"
) { data in
    guard data.starts(with: "<?xml".data(using: .utf8)!) else {
        throw ValidationError()
    }
}
```

### URLRouting Integration

Enable URLRouting support using Swift Package Manager traits:

```swift
// In your Package.swift
dependencies: [
    .package(
        url: "https://github.com/coenttb/swift-multipart-form-coding",
        from: "0.1.0",
        traits: ["URLRouting"]  // Enable URLRouting trait
    )
]
```

Then use with URLRouting:

```swift
import MultipartFormCoding  // URLRouting is conditionally exported when trait is enabled

let avatarUpload = try Multipart.FileUpload(
    fieldName: "avatar",
    filename: "profile.jpg",
    fileType: .image(.jpeg)
)

let uploadRoute = Route {
    Method.post
    Path { "upload" / "avatar" }
    Body(avatarUpload)  // FileUpload conforms to URLRouting.Conversion
}
```

### Codable to Multipart/Form-Data

For encoding Codable types to multipart/form-data (e.g., for API integrations like Mailgun):

```swift
import MultipartFormCoding  // URLRouting trait must be enabled

struct UpdateRequest: Codable {
    let name: String
    let email: String
    let subscribed: Bool
}

let request = UpdateRequest(
    name: "John Doe",
    email: "john@example.com",
    subscribed: true
)

// Create conversion with optional array encoding strategy
let conversion = Multipart.Conversion(
    UpdateRequest.self,
    arrayEncodingStrategy: .accumulateValues  // or .brackets
)

// Encode to multipart/form-data
let multipartData = try conversion.unapply(request)

// Get Content-Type header
let contentType = conversion.contentType  // "multipart/form-data; boundary=..."
```

### Security Features

- **Magic Number Validation**: Verifies file signatures match declared type
- **Size Limits**: Default 10MB, configurable up to 1GB
- **Content Type Validation**: Ensures uploaded content matches expectations
- **Cryptographically Safe Boundaries**: Uses RFC 2046 boundary generation

## URLRouting Trait

The `URLRouting` trait provides integration with PointFree's [swift-url-routing](https://github.com/pointfreeco/swift-url-routing). When enabled, it:
- Makes `Multipart.FileUpload` conform to `URLRouting.Conversion`
- Makes `Multipart.Conversion<T>` conform to `URLRouting.Conversion`
- Provides `.multipart(_:)` convenience method on `Conversion`
- Provides `Field.contentType(_:)` for custom Content-Type headers
- Re-exports URLRouting for convenient access

To run tests with URLRouting support:
```bash
swift test --traits URLRouting
```

## Dependencies

- [swift-rfc-2045](https://github.com/swift-standards/swift-rfc-2045) - MIME Content-Type definitions
- [swift-rfc-2046](https://github.com/swift-standards/swift-rfc-2046) - Multipart boundary generation
- [swift-rfc-7578](https://github.com/swift-standards/swift-rfc-7578) - Multipart/form-data format specification
- [swift-url-routing](https://github.com/pointfreeco/swift-url-routing) - URLRouting integration

## Architecture

This package focuses specifically on **file uploads** in multipart/form-data format. For regular form data without files, use [swift-url-form-coding](https://github.com/coenttb/swift-url-form-coding) which provides `application/x-www-form-urlencoded` encoding.

The packages are **architecturally independent**:
- URL Form Coding: Text-based key-value form data
- Multipart Form Coding: Binary file uploads with metadata

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Related Packages

- [swift-url-form-coding](https://github.com/coenttb/swift-url-form-coding) - URL form encoding/decoding
- [swift-form-coding](https://github.com/coenttb/swift-form-coding) - Umbrella package that re-exports both

## Security

Always validate file uploads server-side. While this package provides client-side validation including magic number checking, **never trust client-provided data**. Always perform server-side validation of file types, sizes, and content.
