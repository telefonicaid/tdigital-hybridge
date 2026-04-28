// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Hybridge",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "Hybridge",
            targets: ["Hybridge"]
        )
    ],
    targets: [
        .target(
            name: "Hybridge",
            path: "ios/Hybridge/Hybridge",
            exclude: ["Hybridge-Prefix.pch"],
            publicHeadersPath: "."
        )
    ]
)
