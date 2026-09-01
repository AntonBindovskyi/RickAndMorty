// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let mainActorIsolated: [SwiftSetting] = [
    .defaultIsolation(MainActor.self)
]

let package = Package(
    name: "Modules",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "Models", targets: ["Models"]),
        .library(name: "NetworkClient", targets: ["NetworkClient"]),
        .library(name: "CharactersStorage", targets: ["CharactersStorage"]),
        .library(name: "CharactersStorageRealm", targets: ["CharactersStorageRealm"]),
        .library(name: "CharactersList", targets: ["CharactersList"]),
        .library(name: "CharacterDetail", targets: ["CharacterDetail"]),
        .library(name: "AppFeature", targets: ["AppFeature"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "1.26.2"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-dependencies",
            from: "1.17.1"
        ),
        .package(
            url: "https://github.com/realm/realm-swift",
            from: "20.0.5"
        ),
        .package(
            url: "https://github.com/kean/Nuke",
            from: "13.2.0"
        ),
    ],
    targets: [

        // MARK: - Domain

        .target(
            name: "Models"
        ),

        // MARK: - INterfaces

        .target(
            name: "NetworkClient",
            dependencies: [
                "Models",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies"),
            ]
        ),

        .target(
            name: "CharactersStorage",
            dependencies: [
                "Models",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies"),
            ]
        ),

        // MARK: - Storage

        .target(
            name: "CharactersStorageRealm",
            dependencies: [
                "Models",
                "CharactersStorage",
                .product(name: "RealmSwift", package: "realm-swift"),
                .product(name: "Dependencies", package: "swift-dependencies"),
            ]
        ),

        // MARK: - Features

        .target(
            name: "CharactersList",
            dependencies: [
                "Models",
                "NetworkClient",
                "CharactersStorage",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "NukeUI", package: "Nuke"),
            ],
            swiftSettings: mainActorIsolated
        ),

        .target(
            name: "CharacterDetail",
            dependencies: [
                "Models",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "NukeUI", package: "Nuke"),
            ],
            swiftSettings: mainActorIsolated
        ),

        .target(
            name: "AppFeature",
            dependencies: [
                "CharactersList",
                "CharacterDetail",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            swiftSettings: mainActorIsolated
        ),

        // MARK: - Tests

        .testTarget(
            name: "NetworkClientTests",
            dependencies: ["NetworkClient"],
            resources: [
                .process("Resources")
            ]
        ),

        .testTarget(
            name: "CharactersStorageRealmTests",
            dependencies: ["CharactersStorageRealm"]
        ),

        .testTarget(
            name: "CharactersListTests",
            dependencies: [
                "CharactersList",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            swiftSettings: mainActorIsolated
        ),

        .testTarget(
            name: "AppFeatureTests",
            dependencies: [
                "AppFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            swiftSettings: mainActorIsolated
        ),
    ],
    swiftLanguageModes: [.v6]
)
