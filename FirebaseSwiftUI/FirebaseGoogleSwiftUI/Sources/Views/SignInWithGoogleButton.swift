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
//  SignInWithGoogleButton.swift
//  FirebaseUI
//
//  Created by Russell Wheatley on 22/05/2025.
//
import FirebaseAuthSwiftUI
import FirebaseCore
import GoogleSignInSwift
import SwiftUI

@MainActor
public struct SignInWithGoogleButton {
  @Environment(AuthService.self) private var authService
  private let googleProvider = GoogleProviderAuthUI()

  let customViewModel = GoogleSignInButtonViewModel(
    scheme: .light,
    style: .wide,
    state: .normal
  )
}

extension SignInWithGoogleButton: View {
  public var body: some View {
    GoogleSignInButton(viewModel: customViewModel) {
      Task {
        try await authService.signIn(googleProvider)
      }
    }
    .accessibilityIdentifier("sign-in-with-google-button")
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  return SignInWithGoogleButton()
    .environment(AuthService())
}
