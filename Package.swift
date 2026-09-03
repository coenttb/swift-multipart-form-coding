// swift-tools-version: 6.3.3

import PackageDescription

let package = Package(
    name: "swift-multipart-form-coding",
    platforms: [
        .macOS("27"),
        .iOS("27"),
        .tvOS("27"),
        .watchOS("27")
    ],
    products: [
        .library(name: "MultipartFormCoding", targets: ["MultipartFormCoding"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-compositions/swift-html-form-coder.git",
            branch: "main"
        )
    ],
    targets: [
        .target(
            name: "MultipartFormCoding",
            dependencies: [
                .product(name: "HTML Form Coder Multipart", package: "swift-html-form-coder")
            ]
        ),
        .testTarget(
            name: "MultipartFormCoding Tests",
            dependencies: [
                .target(name: "MultipartFormCoding")
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
