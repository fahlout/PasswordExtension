// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "PasswordExtension",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(
            name: "PasswordExtension", targets: ["PasswordExtension"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "PasswordExtension",
                path: "PasswordExtension/Classes"
                ),
    ]
)
    
