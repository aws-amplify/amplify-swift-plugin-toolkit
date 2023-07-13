// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import PackageDescription

let platforms: [SupportedPlatform] = [
    .iOS(.v13),
    .macOS(.v10_15),
    .tvOS(.v13),
    .watchOS(.v7)
]
let package = Package(
    name: "AmplifySwiftPluginToolkit",
    platforms: platforms,
    products: [
        .library(
            name: "CognitoIdentityPoolOperations",
            targets: ["CognitoIdentityPoolOperations"]),
        .library(
            name: "SecureStorage",
            targets: ["SecureStorage"])
    ],
    dependencies: [
        .package(url: "https://github.com/awslabs/aws-sdk-swift.git", exact: "0.13.0"),
        .package(url: "https://github.com/aws-amplify/amplify-swift.git", exact: "2.14.0")
    ],
    targets: [
        .target(
            name: "AmplifySwiftPluginToolkit"
        ),
        .target(
            name: "CognitoIdentityPoolOperations",
            dependencies: [
                .product(name: "Amplify", package: "amplify-swift"),
                .product(name: "AWSPluginsCore", package: "amplify-swift"),
                .product(name: "AWSCognitoIdentity", package: "aws-sdk-swift"),
                "SecureStorage",
                "AmplifySwiftPluginToolkit"
            ]
        ),
        .target(
            name: "SecureStorage",
            dependencies: [
                .product(name: "Amplify", package: "amplify-swift"),
                .product(name: "AWSPluginsCore", package: "amplify-swift")
            ]
        ),
        .testTarget(
            name: "CognitoIdentityPoolOperationsTests",
            dependencies: [
                .product(name: "Amplify", package: "amplify-swift"),
                .product(name: "AWSPluginsCore", package: "amplify-swift"),
                "CognitoIdentityPoolOperations",
                "SecureStorage"
            ]
        ),
        .testTarget(
            name: "SecureStorageTests",
            dependencies: [
                .product(name: "Amplify", package: "amplify-swift"),
                .product(name: "AWSPluginsCore", package: "amplify-swift"),
                "SecureStorage"
            ]
        )
    ]
)
