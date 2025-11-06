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
import FirebaseAuthUIComponents
import SwiftUI

/// A button for signing in with Apple
@MainActor
public struct SignInWithAppleButton {
  @Environment(AuthService.self) private var authService
  let provider: AppleProviderSwift
  public init(provider: AppleProviderSwift) {
    self.provider = provider
  }
}

extension SignInWithAppleButton: View {
  public var body: some View {
    AuthProviderButton(
      label: authService.string.appleLoginButtonLabel,
      style: .apple,
      accessibilityId: "sign-in-with-apple-button"
    ) {
      Task {
        try? await authService.signIn(provider)
      }
    }
  }
}
