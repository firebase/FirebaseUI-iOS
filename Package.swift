// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright 2020 Google LLC
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
  platforms: [.iOS(.v10)],
  products: [
    .library(
      name: "AnonymousAuthUI",
      targets: ["AnonymousAuthUI"]
    ),
    .library(
      name: "DatabaseUI",
      targets: ["DatabaseUI"]
    ),
    .library(
      name: "AuthUI",
      targets: ["AuthUI"]
    ),
    .library(
      name: "EmailAuthUI",
      targets: ["EmailAuthUI"]
    ),
    .library(
      name: "FirestoreUI",
      targets: ["FirestoreUI"]
    ),
    .library(
      name: "OAuthUI",
      targets: ["OAuthUI"]
    ),
    .library(
      name: "PhoneAuthUI",
      targets: ["PhoneAuthUI"]
    ),
    .library(
      name: "StorageUI",
      targets: ["StorageUI"]
    ),
  ],
  dependencies: [
    .package(
      name: "Facebook", 
      url: "https://github.com/facebook/facebook-ios-sdk.git",
      from: "9.0.0"
    ),
    .package(
      name: "Firebase", 
      url: "https://github.com/firebase/firebase-ios-sdk.git",
      from: "7.2.0"
    ),
    .package(
      name: "GoogleUtilities",
      url: "https://github.com/google/GoogleUtilities.git",
      "7.2.1" ..< "8.0.0"
    ),
    .package(
      name: "GTMSessionFetcher",
      url: "https://github.com/google/gtm-session-fetcher.git",
      "1.4.0" ..< "2.0.0"
    ),
    .package(
      name: "SDWebImage",
      url: "https://github.com/SDWebImage/SDWebImage.git",
      from: "5.0.0"
    ),
  ],
  targets: [
    .target(
      name: "AnonymousAuthUI",
      dependencies: ["AuthUI"],
      path: "AnonymousAuth/FirebaseAnonymousAuthUI",
      exclude: ["Info.plist"],
      resources: [
        .process("Resources"),
        .process("Strings"),
      ],
      publicHeadersPath: ".",
      cSettings: [
        .headerSearchPath("./"),
      ]
    ),
    .target(
      name: "DatabaseUI",
      dependencies: [
        .product(name: "FirebaseDatabase", package: "Firebase"),
      ],
      path: "Database/FirebaseDatabaseUI",
      exclude: ["Info.plist"],
      resources: nil,
      publicHeadersPath: ".",
      cSettings: [
        .headerSearchPath("./"),
      ]
    ),
    .target(
      name: "AuthUI",
      dependencies: [
        .product(name: "FirebaseAuth", package: "Firebase"),
        .product(name: "GULUserDefaults", package: "GoogleUtilities"),
      ],
      path: "Auth/FirebaseAuthUI",
      exclude: ["Info.plist"],
      resources: [
        .process("Resources"),
        .process("Strings"),
        .process("AccountManagement/FUIAccountSettingsViewController.xib"),
        .process("AccountManagement/FUIInputTableViewCell.xib"),
        .process("AccountManagement/FUIPasswordTableViewCell.xib"),
        .process("FUIAuthPickerViewController.xib"),
        .process("FUIAuthTableViewCell.xib"),
        .process("FUIStaticContentTableViewController.xib"),
      ],
      publicHeadersPath: ".",
      cSettings: [
        .headerSearchPath("./"),
        .headerSearchPath("./AccountManagement/"),
      ]
    ),
    .target(
      name: "EmailAuthUI",
      dependencies: ["AuthUI"],
      path: "EmailAuth/FirebaseEmailAuthUI",
      exclude: ["Info.plist"],
      resources: [
        .process("Resources"),
      ],
      publicHeadersPath: ".",
      cSettings: [
        .headerSearchPath("./"),
      ]
    ),
    // Facebook doesn't seem to vend their ObjC libraries through SPM, though thier
    // Swift libraries wrap their ObjC ones.
//    .target(
//      name: "FacebookAuthUI",
//      dependencies: [
//        "AuthUI",
//        .product(name: "FacebookLogin", package: "Facebook"),
//        .product(name: "FacebookCore", package: "Facebook"),
//      ],
//      path: "FacebookAuth/FirebaseFacebookAuthUI",
//      exclude: ["Info.plist"],
//      resources: [
//        .process("Resources"),
//        .process("Strings"),
//      ],
//      publicHeadersPath: ".",
//      cSettings: [
//        .headerSearchPath("./"),
//      ]
//    ),
    .target(
      name: "FirestoreUI",
      dependencies: [
        .product(name: "FirebaseFirestore", package: "Firebase"),
      ],
      path: "Firestore/FirebaseFirestoreUI",
      exclude: ["Info.plist"],
      resources: nil,
      publicHeadersPath: ".",
      cSettings: [
        .headerSearchPath("./"),
      ]
    ),
    // .target(
    //   name: "GoogleAuthUI",
    //   dependencies: [
    //     "AuthUI",
    //     // missing google auth dependency
    //   ],
    //   path: "GoogleAuth/FirebaseGoogleAuthUI",
    //   exclude: ["Info.plist"],
    //   resources: [
    //     .process("Resources"),
    //     .process("Strings"),
    //   ],
    //   publicHeadersPath: ".",
    //   cSettings: [
    //     .headerSearchPath("./"),
    //   ]
    // ),
    .target(
      name: "OAuthUI",
      dependencies: [
        "AuthUI",
      ],
      path: "OAuth/FirebaseOAuthUI",
      exclude: ["Info.plist"],
      resources: [
        .process("Resources"),
      ],
      publicHeadersPath: ".",
      cSettings: [
        .headerSearchPath("./"),
      ]
    ),
    .target(
      name: "PhoneAuthUI",
      dependencies: [
        "AuthUI",
      ],
      path: "PhoneAuth/FirebasePhoneAuthUI",
      exclude: ["Info.plist"],
      resources: [
        .process("Resources"),
        .process("Strings"),
        .process("CountryCode/FUICountryTableViewController.xib"),
        .process("FUIPhoneEntryViewController.xib"),
        .process("FUIPhoneVerificationViewController.xib"),
      ],
      publicHeadersPath: ".",
      cSettings: [
        .headerSearchPath("./"),
        .headerSearchPath("./CountryCode/"),
      ]
    ),
    .target(
      name: "StorageUI",
      dependencies: [
        .product(name: "FirebaseStorage", package: "Firebase"),
        .product(name: "SDWebImage", package: "SDWebImage"),
        .product(name: "GTMSessionFetcher", package: "GTMSessionFetcher"),
      ],
      path: "Storage/FirebaseStorageUI",
      exclude: ["Info.plist"],
      resources: nil,
      publicHeadersPath: ".",
      cSettings: [
        .headerSearchPath("./"),
        .headerSearchPath("./CountryCode/"),
      ]
    ),
  ]
)
