// swift-tools-version: 6.3.3

import PackageDescription

extension String {
    static let multipartFormCoding: Self = "MultipartFormCoding"
}

extension String { var tests: Self { self + " Tests" } }

extension Target.Dependency {
    static var multipartFormCoding: Self { .target(name: .multipartFormCoding) }
    static var htmlFormCoderMultipart: Self {
        .product(name: "HTML Form Coder Multipart", package: "swift-html-form-coder")
    }
}

let package = Package(
    name: "swift-multipart-form-coding",
    platforms: [
        .macOS("27"),
        .iOS("27"),
        .tvOS("27"),
        .watchOS("27")
    ],
    products: [
        .library(name: .multipartFormCoding, targets: [.multipartFormCoding])
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-foundations/swift-html-form-coder.git",
            branch: "main"
        )
    ],
    targets: [
        .target(
            name: .multipartFormCoding,
            dependencies: [
                .htmlFormCoderMultipart
            ]
        ),
        .testTarget(
            name: .multipartFormCoding.tests,
            dependencies: [
                .multipartFormCoding
            ],
            path: "Tests/Multipart Form Coding Tests"
        ),
    ]
)

for target in package.targets {
    target.swiftSettings = (target.swiftSettings ?? []) + [
        .enableUpcomingFeature("MemberImportVisibility")
    ]
}
