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

import FirebaseCore
import SwiftUI

@MainActor
public struct SignedInView {
  @Environment(AuthService.self) private var authService
}

extension SignedInView: View {
  private var isShowingPasswordPrompt: Binding<Bool> {
    Binding(
      get: { authService.passwordPrompt.isPromptingPassword },
      set: { authService.passwordPrompt.isPromptingPassword = $0 }
    )
  }

  public var body: some View {
    if authService.authView == .updatePassword {
      UpdatePasswordView()
    } else {
      VStack {
        Text(authService.string.signedInTitle)
          .font(.largeTitle)
          .fontWeight(.bold)
          .padding()
          .accessibilityIdentifier("signed-in-text")
        Text("as:")
        Text("\(authService.currentUser?.email ?? authService.currentUser?.displayName ?? "Unknown")")
        if authService.currentUser?.isEmailVerified == false {
          VerifyEmailView()
        }
        Divider()
        Button(authService.string.updatePasswordButtonLabel) {
          authService.authView = .updatePassword
        }
        Divider()
        Button("Manage Two-Factor Authentication") {
          authService.authView = .mfaManagement
        }
        .accessibilityIdentifier("mfa-management-button")
        Divider()
        Button(authService.string.signOutButtonLabel) {
          Task {
            try? await authService.signOut()
          }
        }.accessibilityIdentifier("sign-out-button")
        Divider()
        Button(authService.string.deleteAccountButtonLabel) {
          Task {
            try? await authService.deleteUser()
          }
        }
      }
      .sheet(isPresented: isShowingPasswordPrompt) {
        PasswordPromptSheet(coordinator: authService.passwordPrompt)
      }
    }
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  return SignedInView()
    .environment(AuthService())
}
