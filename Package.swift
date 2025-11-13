// swift-tools-version:6.1

import PackageDescription

extension String {
    static let multipartFormCoding: Self = "MultipartFormCoding"
    static let multipartFormCodingURLRouting: Self = "MultipartFormCodingURLRouting"
}

extension Target.Dependency {
    static var multipartFormCoding: Self { .target(name: .multipartFormCoding) }
    static var multipartFormCodingURLRouting: Self { .target(name: .multipartFormCodingURLRouting) }
    static var rfc2045: Self { .product(name: "RFC 2045", package: "swift-rfc-2045") }
    static var rfc2046: Self { .product(name: "RFC 2046", package: "swift-rfc-2046") }
    static var rfc7578: Self { .product(name: "RFC 7578", package: "swift-rfc-7578") }
    static var urlRouting: Self { .product(name: "URLRouting", package: "swift-url-routing") }
}

let package = Package(
    name: "swift-multipart-form-coding",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .tvOS(.v17),
        .watchOS(.v10)
    ],
    products: [
        .library(name: .multipartFormCoding, targets: [.multipartFormCoding]),
        .library(name: .multipartFormCodingURLRouting, targets: [.multipartFormCodingURLRouting])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-standards/swift-rfc-2045.git", from: "0.1.0"),
        .package(url: "https://github.com/swift-standards/swift-rfc-2046.git", from: "0.1.3"),
        .package(url: "https://github.com/swift-standards/swift-rfc-7578.git", from: "0.2.1"),
        .package(url: "https://github.com/pointfreeco/swift-url-routing", from: "0.6.0")
    ],
    targets: [
        .target(
            name: .multipartFormCoding,
            dependencies: [
                .rfc2045,
                .rfc2046
            ]
        ),
        .testTarget(
            name: .multipartFormCoding.tests,
            dependencies: [
                .multipartFormCoding
            ]
        ),
        .target(
            name: .multipartFormCodingURLRouting,
            dependencies: [
                .multipartFormCoding,
                .rfc2045,
                .rfc2046,
                .rfc7578,
                .urlRouting
            ]
        ),
        .testTarget(
            name: .multipartFormCodingURLRouting.tests,
            dependencies: [
                .multipartFormCoding,
                .multipartFormCodingURLRouting
            ]
        )
    ]
)

extension String { var tests: Self { self + " Tests" } }
