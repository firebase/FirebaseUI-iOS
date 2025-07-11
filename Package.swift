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
      name: "FirebaseAnonymousAuthUI",
      targets: ["FirebaseAnonymousAuthUI"]
    ),
    .library(
      name: "FirebaseDatabaseUI",
      targets: ["FirebaseDatabaseUI"]
    ),
    .library(
      name: "FirebaseAuthUI",
      targets: ["FirebaseAuthUI"]
    ),
    .library(
      name: "FirebaseEmailAuthUI",
      targets: ["FirebaseEmailAuthUI"]
    ),
    .library(
      name: "FirebaseFacebookAuthUI",
      targets: ["FirebaseFacebookAuthUI"]
    ),
    .library(
      name: "FirebaseFirestoreUI",
      targets: ["FirebaseFirestoreUI"]
    ),
    .library(
      name: "FirebaseGoogleAuthUI",
      targets: ["FirebaseGoogleAuthUI"]
    ),
    .library(
      name: "FirebaseOAuthUI",
      targets: ["FirebaseOAuthUI"]
    ),
    .library(
      name: "FirebasePhoneAuthUI",
      targets: ["FirebasePhoneAuthUI"]
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
  ],
  dependencies: [
    .package(
      name: "Facebook",
      url: "https://github.com/facebook/facebook-ios-sdk.git",
      "17.0.0" ..< "18.0.0"
    ),
    .package(
      name: "Firebase",
      url: "https://github.com/firebase/firebase-ios-sdk.git",
      "8.0.0" ..< "13.0.0"
    ),
    .package(
      name: "GoogleSignIn",
      url: "https://github.com/google/GoogleSignIn-iOS",
      from: "7.0.0"
    ),
    .package(
      name: "GoogleUtilities",
      url: "https://github.com/google/GoogleUtilities.git",
      "7.4.1" ..< "9.0.0"
    ),
    .package(
      name: "SDWebImage",
      url: "https://github.com/SDWebImage/SDWebImage.git",
      from: "5.0.0"
    ),
  ],
  targets: [
    .target(
      name: "FirebaseAnonymousAuthUI",
      dependencies: ["FirebaseAuthUI"],
      path: "FirebaseAnonymousAuthUI/Sources",
      exclude: ["Info.plist"],
      resources: [
        .process("Resources"),
        .process("Strings"),
      ],
      publicHeadersPath: "Public",
      cSettings: [
        .headerSearchPath("../../"),
      ]
    ),
    .target(
      name: "FirebaseDatabaseUI",
      dependencies: [
        .product(name: "FirebaseDatabase", package: "Firebase"),
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
      name: "FirebaseAuthUI",
      dependencies: [
        .product(name: "FirebaseAuth", package: "Firebase"),
        .product(name: "GULUserDefaults", package: "GoogleUtilities"),
      ],
      path: "FirebaseAuthUI/Sources",
      exclude: ["Info.plist"],
      resources: [
        .process("Resources"),
        .process("Strings"),
      ],
      publicHeadersPath: "Public",
      cSettings: [
        .headerSearchPath("../../"),
      ]
    ),
    .target(
      name: "FirebaseEmailAuthUI",
      dependencies: ["FirebaseAuthUI"],
      path: "FirebaseEmailAuthUI/Sources",
      exclude: ["Info.plist"],
      resources: [
        .process("Resources"),
      ],
      publicHeadersPath: "Public",
      cSettings: [
        .headerSearchPath("../../"),
      ]
    ),
    .target(
      name: "FirebaseFacebookAuthUI",
      dependencies: [
        "FirebaseAuthUI",
        .product(name: "FacebookLogin", package: "Facebook"),
        .product(name: "FacebookCore", package: "Facebook"),
      ],
      path: "FirebaseFacebookAuthUI/Sources",
      exclude: ["Info.plist"],
      resources: [
        .process("Resources"),
        .process("Strings"),
      ],
      publicHeadersPath: "Public",
      cSettings: [
        .headerSearchPath("../../"),
      ]
    ),
    .target(
      name: "FirebaseFirestoreUI",
      dependencies: [
        .product(name: "FirebaseFirestore", package: "Firebase"),
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
      name: "FirebaseGoogleAuthUI",
      dependencies: [
        "FirebaseAuthUI",
        "GoogleSignIn",
      ],
      path: "FirebaseGoogleAuthUI/Sources",
      exclude: ["Info.plist"],
      resources: [
        .process("Resources"),
        .process("Strings"),
      ],
      publicHeadersPath: "Public",
      cSettings: [
        .headerSearchPath("../../"),
      ]
    ),
    .target(
      name: "FirebaseOAuthUI",
      dependencies: [
        "FirebaseAuthUI",
      ],
      path: "FirebaseOAuthUI/Sources",
      exclude: ["Info.plist"],
      resources: [
        .process("Resources"),
      ],
      publicHeadersPath: "Public",
      cSettings: [
        .headerSearchPath("../../"),
      ]
    ),
    .target(
      name: "FirebasePhoneAuthUI",
      dependencies: [
        "FirebaseAuthUI",
      ],
      path: "FirebasePhoneAuthUI/Sources",
      exclude: ["Info.plist"],
      resources: [
        .process("Resources"),
        .process("Strings"),
      ],
      publicHeadersPath: "Public",
      cSettings: [
        .headerSearchPath("../../"),
      ]
    ),
    .target(
      name: "FirebaseStorageUI",
      dependencies: [
        .product(name: "FirebaseStorage", package: "Firebase"),
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
      name: "FirebaseAuthSwiftUI",
      dependencies: [
        .product(name: "FirebaseAuth", package: "Firebase"),
      ],
      path: "FirebaseSwiftUI/FirebaseAuthSwiftUI/Sources",
      resources: [
        .process("Strings"),
      ]
    ),
    .testTarget(
      name: "FirebaseAuthSwiftUITests",
      dependencies: ["FirebaseAuthSwiftUI"],
      path: "FirebaseSwiftUI/FirebaseAuthSwiftUI/Tests/"
    ),
    .target(
      name: "FirebaseGoogleSwiftUI",
      dependencies: [
        "FirebaseAuthSwiftUI",
        "GoogleSignIn",
        .product(name: "GoogleSignInSwift", package: "GoogleSignIn"),
      ],
      path: "FirebaseSwiftUI/FirebaseGoogleSwiftUI/Sources"
    ),
    .testTarget(
      name: "FirebaseGoogleSwiftUITests",
      dependencies: ["FirebaseGoogleSwiftUI"],
      path: "FirebaseSwiftUI/FirebaseGoogleSwiftUI/Tests/"
    ),
    .target(
      name: "FirebaseFacebookSwiftUI",
      dependencies: [
        "FirebaseAuthSwiftUI",
        .product(name: "FacebookLogin", package: "Facebook"),
        .product(name: "FacebookCore", package: "Facebook"),
      ],
      path: "FirebaseSwiftUI/FirebaseFacebookSwiftUI/Sources"
    ),
    .testTarget(
      name: "FirebaseFacebookSwiftUITests",
      dependencies: ["FirebaseFacebookSwiftUI"],
      path: "FirebaseSwiftUI/FirebaseFacebookSwiftUI/Tests/"
    ),
    .target(
      name: "FirebasePhoneAuthSwiftUI",
      dependencies: [
        "FirebaseAuthSwiftUI",
      ],
      path: "FirebaseSwiftUI/FirebasePhoneAuthSwiftUI/Sources"
    ),
    .testTarget(
      name: "FirebasePhoneAuthSwiftUITests",
      dependencies: ["FirebasePhoneAuthSwiftUI"],
      path: "FirebaseSwiftUI/FirebasePhoneAuthSwiftUI/Tests/"
    ),
  ]
)
