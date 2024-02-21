// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AuroraEditorTextView",
    platforms: [.macOS(.v12)],
    products: [
        .library(
            name: "AuroraEditorTextView",
            targets: ["AuroraEditorTextView"]
        ),
        .library(
            name: "AuroraEditorInputView",
            targets: ["AuroraEditorInputView"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/ChimeHQ/SwiftTreeSitter.git",
            exact: "0.7.1"
        ),
        .package(
            url: "https://github.com/apple/swift-collections.git",
            .upToNextMajor(from: "1.0.0")
        ),
        .package(
            url: "https://github.com/AuroraEditor/AuroraEditorLanguage",
            branch: "main"
        ),
        .package(
            url: "https://github.com/AuroraEditor/AETVThirdParty",
            branch: "main"
        )
    ],
    targets: [
        .target(
            name: "AuroraEditorTextView",
            dependencies: [
                "AuroraEditorInputView",
                "AuroraEditorLanguage",
                .product(name: "AETextViewThirdParty", package: "AETVThirdParty")
            ]
        ),
        .target(
            name: "AuroraEditorInputView",
            dependencies: [
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "AETextViewThirdParty", package: "AETVThirdParty")
            ]
        )
    ]
)
