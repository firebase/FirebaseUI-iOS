// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  AuthService+Google.swift
//  FirebaseUI
//
//  Created by Morgan Chen on 4/16/25.
//

import FirebaseAuthSwiftUI

public extension AuthService {
  @discardableResult
  func withGoogleSignIn(_ provider: GoogleProviderSwift? = nil) -> AuthService {
    registerProvider(providerWithButton: GoogleProviderAuthUI(provider: provider ??
        GoogleProviderSwift(clientID: auth.app?.options.clientID ?? "")))
    return self
  }
}
