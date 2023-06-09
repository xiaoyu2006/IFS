// swift-tools-version: 5.6

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "IFS",
    platforms: [
        .iOS("15.2")
    ],
    products: [
        .iOSApplication(
            name: "IFS",
            targets: ["AppModule"],
            bundleIdentifier: "top.ycao.IFS",
            teamIdentifier: "Y46NWTBFRF",
            displayVersion: "0.1",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .pencil),
            accentColor: .presetColor(.teal),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .landscapeRight,
                .landscapeLeft
            ],
            capabilities: [
                .photoLibraryAdd(purposeString: "Save rendered image.")
            ],
            appCategory: .education
        )
    ],
    dependencies: [
        .package(url: "https://github.com/asam139/Steps", "0.3.7"..<"1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            dependencies: [
                .product(name: "Steps", package: "steps")
            ],
            path: "."
        )
    ]
)