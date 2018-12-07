// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "MoreCodable",
    products: [
        .library(name: "MoreCodable", targets: ["MoreCodable"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MoreCodable", 
            path: "Sources/",
            exclude: []
        )
    ],
    swiftLanguageVersions: [4]
)
