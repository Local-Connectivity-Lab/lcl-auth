// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "lcl-auth",
    platforms: [.iOS(.v13), .macOS(.v11), .tvOS(.v13), .watchOS(.v6)],
    products: [
        .library(name: "LCLAuth", targets: ["LCLAuth"])
    ],
    dependencies: [
        .package(url: "https://github.com/johnnzhou/lcl-k1.git", branch: "main"),
        .package(url: "https://github.com/johnnzhou/swift-crypto.git", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "LCLAuth",
            dependencies: [
                .product(name: "LCLK1", package: "lcl-k1"),
                .product(name: "Crypto", package: "swift-crypto")
            ]
        ),
        .testTarget(name: "ECDSATests", dependencies: ["LCLAuth"])
    ]
)
