// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "payload-validation",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "PayloadValidation",
            targets: ["PayloadValidation"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0")
    ],
    targets: [
        .target(
            name: "PayloadValidation",
            dependencies: [
                .product(name: "Vapor", package: "vapor")
            ]),
        .testTarget(
            name: "PayloadValidationTests",
            dependencies: [
                .target(name: "PayloadValidation"),
                .product(name: "XCTVapor", package: "vapor")
            ]),
    ]
)
