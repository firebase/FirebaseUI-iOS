// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright 2021 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import PackageDescription

let package = Package(
  name: "FirebaseUI",
  defaultLocalization: "en",
  platforms: [.iOS(.v17)],
  products: [
    .library(
      name: "FirebaseDatabaseUI",
      targets: ["FirebaseDatabaseUI"]
    ),
    .library(
      name: "FirebaseFirestoreUI",
      targets: ["FirebaseFirestoreUI"]
    ),
    .library(
      name: "FirebaseStorageUI",
      targets: ["FirebaseStorageUI"]
    ),
    .library(
      name: "FirebaseAuthSwiftUI",
      targets: ["FirebaseAuthSwiftUI"]
    ),
    .library(
      name: "FirebaseGoogleSwiftUI",
      targets: ["FirebaseGoogleSwiftUI"]
    ),
    .library(
      name: "FirebaseFacebookSwiftUI",
      targets: ["FirebaseFacebookSwiftUI"]
    ),
    .library(
      name: "FirebasePhoneAuthSwiftUI",
      targets: ["FirebasePhoneAuthSwiftUI"]
    ),
    .library(
      name: "FirebaseTwitterSwiftUI",
      targets: ["FirebaseTwitterSwiftUI"]
    ),
    .library(
      name: "FirebaseAppleSwiftUI",
      targets: ["FirebaseAppleSwiftUI"]
    ),
    .library(
      name: "FirebaseOAuthSwiftUI",
      targets: ["FirebaseOAuthSwiftUI"]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/facebook/facebook-ios-sdk.git",
      "18.0.0" ..< "19.0.0"
    ),
    .package(
      url: "https://github.com/firebase/firebase-ios-sdk.git",
      "8.0.0" ..< "13.0.0"
    ),
    .package(
      url: "https://github.com/google/GoogleSignIn-iOS",
      from: "7.0.0"
    ),
    .package(
      url: "https://github.com/google/GoogleUtilities.git",
      "7.4.1" ..< "9.0.0"
    ),
    .package(
      url: "https://github.com/SDWebImage/SDWebImage.git",
      from: "5.0.0"
    ),
  ],
  targets: [
    .target(
      name: "FirebaseDatabaseUI",
      dependencies: [
        .product(name: "FirebaseDatabase", package: "firebase-ios-sdk"),
      ],
      path: "FirebaseDatabaseUI/Sources",
      exclude: ["Info.plist"],
      resources: nil,
      publicHeadersPath: "Public",
      cSettings: [
        .headerSearchPath("../../"),
      ]
    ),
    .target(
      name: "FirebaseFirestoreUI",
      dependencies: [
        .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
      ],
      path: "FirebaseFirestoreUI/Sources",
      exclude: ["Info.plist"],
      resources: nil,
      publicHeadersPath: "Public",
      cSettings: [
        .headerSearchPath("../../"),
      ]
    ),
    .target(
      name: "FirebaseStorageUI",
      dependencies: [
        .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
        .product(name: "SDWebImage", package: "SDWebImage"),
      ],
      path: "FirebaseStorageUI/Sources",
      exclude: ["Info.plist"],
      resources: nil,
      publicHeadersPath: "Public",
      cSettings: [
        .headerSearchPath("../../"),
      ]
    ),
    .target(
      name: "FirebaseAuthUIComponents",
      dependencies: [],
      path: "FirebaseSwiftUI/FirebaseAuthUIComponents/Sources",
      resources: [
        .process("Resources"),
      ]
    ),
    .target(
      name: "FirebaseAuthSwiftUI",
      dependencies: [
        "FirebaseAuthUIComponents",
        .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
      ],
      path: "FirebaseSwiftUI/FirebaseAuthSwiftUI/Sources",
      resources: [
        .process("Strings"),
      ],
      swiftSettings: [
        .swiftLanguageMode(.v6),
      ]
    ),
    .testTarget(
      name: "FirebaseAuthSwiftUITests",
      dependencies: ["FirebaseAuthSwiftUI"],
      path: "FirebaseSwiftUI/FirebaseAuthSwiftUI/Tests/",
      swiftSettings: [
        .swiftLanguageMode(.v6),
      ]
    ),
    .target(
      name: "FirebaseGoogleSwiftUI",
      dependencies: [
        "FirebaseAuthSwiftUI",
        "FirebaseAuthUIComponents",
        .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
        .product(name: "GoogleSignInSwift", package: "GoogleSignIn-iOS"),
      ],
      path: "FirebaseSwiftUI/FirebaseGoogleSwiftUI/Sources",
      swiftSettings: [
        .swiftLanguageMode(.v6),
      ]
    ),
    .testTarget(
      name: "FirebaseGoogleSwiftUITests",
      dependencies: ["FirebaseGoogleSwiftUI"],
      path: "FirebaseSwiftUI/FirebaseGoogleSwiftUI/Tests/",
      swiftSettings: [
        .swiftLanguageMode(.v6),
      ]
    ),
    .target(
      name: "FirebaseFacebookSwiftUI",
      dependencies: [
        "FirebaseAuthSwiftUI",
        "FirebaseAuthUIComponents",
        .product(name: "FacebookLogin", package: "facebook-ios-sdk"),
        .product(name: "FacebookCore", package: "facebook-ios-sdk"),
      ],
      path: "FirebaseSwiftUI/FirebaseFacebookSwiftUI/Sources",
      swiftSettings: [
        .swiftLanguageMode(.v6),
      ]
    ),
    .testTarget(
      name: "FirebaseFacebookSwiftUITests",
      dependencies: ["FirebaseFacebookSwiftUI"],
      path: "FirebaseSwiftUI/FirebaseFacebookSwiftUI/Tests/",
      swiftSettings: [
        .swiftLanguageMode(.v6),
      ]
    ),
    .target(
      name: "FirebasePhoneAuthSwiftUI",
      dependencies: [
        "FirebaseAuthSwiftUI",
        "FirebaseAuthUIComponents",
      ],
      path: "FirebaseSwiftUI/FirebasePhoneAuthSwiftUI/Sources",
      swiftSettings: [
        .swiftLanguageMode(.v6),
      ]
    ),
    .testTarget(
      name: "FirebasePhoneAuthSwiftUITests",
      dependencies: ["FirebasePhoneAuthSwiftUI"],
      path: "FirebaseSwiftUI/FirebasePhoneAuthSwiftUI/Tests/",
      swiftSettings: [
        .swiftLanguageMode(.v6),
      ]
    ),
    .target(
      name: "FirebaseTwitterSwiftUI",
      dependencies: [
        "FirebaseAuthSwiftUI",
        "FirebaseAuthUIComponents",
      ],
      path: "FirebaseSwiftUI/FirebaseTwitterSwiftUI/Sources",
      swiftSettings: [
        .swiftLanguageMode(.v6),
      ]
    ),
    .testTarget(
      name: "FirebaseTwitterSwiftUITests",
      dependencies: ["FirebaseTwitterSwiftUI"],
      path: "FirebaseSwiftUI/FirebaseTwitterSwiftUI/Tests/",
      swiftSettings: [
        .swiftLanguageMode(.v6),
      ]
    ),
    .target(
      name: "FirebaseAppleSwiftUI",
      dependencies: [
        "FirebaseAuthSwiftUI",
        "FirebaseAuthUIComponents",
      ],
      path: "FirebaseSwiftUI/FirebaseAppleSwiftUI/Sources",
      swiftSettings: [
        .swiftLanguageMode(.v6),
      ]
    ),
    .testTarget(
      name: "FirebaseAppleSwiftUITests",
      dependencies: ["FirebaseAppleSwiftUI"],
      path: "FirebaseSwiftUI/FirebaseAppleSwiftUI/Tests/",
      swiftSettings: [
        .swiftLanguageMode(.v6),
      ]
    ),
    .target(
      name: "FirebaseOAuthSwiftUI",
      dependencies: [
        "FirebaseAuthSwiftUI",
        "FirebaseAuthUIComponents",
      ],
      path: "FirebaseSwiftUI/FirebaseOAuthSwiftUI/Sources",
      swiftSettings: [
        .swiftLanguageMode(.v6),
      ]
    ),
    .testTarget(
      name: "FirebaseOAuthSwiftUITests",
      dependencies: ["FirebaseOAuthSwiftUI"],
      path: "FirebaseSwiftUI/FirebaseOAuthSwiftUI/Tests/",
      swiftSettings: [
        .swiftLanguageMode(.v6),
      ]
    ),
  ]
)
