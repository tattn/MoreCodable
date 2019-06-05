// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "MoreCodable",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v10),
        .tvOS(.v10),
        .watchOS(.v3)
    ],
    products: [
        .library(
            name: "MoreCodable",
            targets: ["MoreCodable"])
    ],
    targets: [
        .target(
            name: "MoreCodable",
            path: "Sources")
    ],
    swiftLanguageVersions: [.v5]
)

