// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "glassy_ui_ios",
    platforms: [
        .iOS("17.0")
    ],
    products: [
        .library(name: "glassy-ui-ios", targets: ["glassy_ui_ios"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "glassy_ui_ios",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            resources: [
                // The plugin collects no data and uses no required-reason APIs.
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
