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
  platforms: [.iOS(.v9)],
  products: [
    .library(
      name: "AuthUI",
      targets: ["AuthUI"]
    ),
    .library(
      name: "EmailUI",
      targets: ["EmailUI"]
    ),
  ],
  dependencies: [

    .package(name: "Firebase", url: "https://github.com/firebase/firebase-ios-sdk.git",
             .branch("6.32-spm-beta")),
  ],
  targets: [
    .target(
      name: "AuthUI",
      dependencies: [
        .product(name: "FirebaseAuth", package: "Firebase"),
        .product(name: "GoogleUtilities_UserDefaults", package: "Firebase"),
      ],
      path: "Auth/FirebaseAuthUI",
      exclude: ["Info.plist"],
      resources: [.process("Resources")],
      publicHeadersPath: ".",
      cSettings: [
        .headerSearchPath("./"),
        .headerSearchPath("./AccountManagement/"),
      ]
    ),
    .target(
      name: "EmailUI",
      dependencies: ["AuthUI"],
      path: "EmailAuth/FirebaseEmailAuthUI",
      exclude: ["Info.plist"],
      resources: [.process("Resources")],
      publicHeadersPath: ".",
      cSettings: [
        .headerSearchPath("./"),
//        .headerSearchPath("../../Auth/FirebaseAuthUI")
      ]
    ),
    .target(
      name: "PhoneUI",
      dependencies: ["AuthUI"],
      path: "PhoneAuth/FirebasePhoneAuthUI",
      exclude: ["Info.plist"],
      resources: [.process("Resources")],
      publicHeadersPath: ".",
      cSettings: [
        .headerSearchPath("./"),
//        .headerSearchPath("../../Auth/FirebaseAuthUI")
      ]
    ),
  ]
)
