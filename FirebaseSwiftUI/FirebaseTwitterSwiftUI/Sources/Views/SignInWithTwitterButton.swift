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

import FirebaseAuthSwiftUI
import SwiftUI

/// A button for signing in with Twitter/X
@MainActor
public struct SignInWithTwitterButton {
  @Environment(AuthService.self) private var authService
  let provider: AuthProviderSwift
  public init(provider: AuthProviderSwift) {
    self.provider = provider
  }
}

extension SignInWithTwitterButton: View {
  public var body: some View {
    Button(action: {
      Task {
        try await authService.signIn(provider)
      }
    }) {
      HStack {
        Image("twitter_logo", bundle: .module)
          .resizable()
          .renderingMode(.template)
          .scaledToFit()
          .frame(width: 24, height: 24)
          .foregroundColor(.white)
        Text("Sign in with X")
          .fontWeight(.semibold)
          .foregroundColor(.white)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding()
      .background(Color.black)
      .cornerRadius(8)
    }
    .accessibilityIdentifier("sign-in-with-twitter-button")
  }
}
