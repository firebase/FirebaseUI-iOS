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
    VStack {
      Text(authService.string.signedInTitle)
        .font(.largeTitle)
        .fontWeight(.bold)
        .padding()
        .accessibilityIdentifier("signed-in-text")
      Text(
        "\(authService.currentUser?.email ?? authService.currentUser?.displayName ?? "Unknown")"
      )
      if authService.currentUser?.isEmailVerified == false {
        VerifyEmailView()
      }
      Button(action: {
        authService.navigator.push(.updatePassword)
      }) {
        Text(authService.string.updatePasswordButtonLabel)
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity)
      }
      .padding([.top, .bottom], 8)
      .frame(maxWidth: .infinity)
      .buttonStyle(.borderedProminent)
      Button(action: {
        authService.navigator.push(.mfaManagement)
      }) {
        Text("Manage Two-Factor Authentication")
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity)
      }
      .padding([.top, .bottom], 8)
      .frame(maxWidth: .infinity)
      .buttonStyle(.borderedProminent)
      .accessibilityIdentifier("mfa-management-button")
      Button(action: {
        Task {
          try? await authService.signOut()
        }
      }) {
        Text(authService.string.signOutButtonLabel)
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity)
      }
      .padding([.top, .bottom], 8)
      .frame(maxWidth: .infinity)
      .buttonStyle(.borderedProminent)
      .accessibilityIdentifier("sign-out-button")
      Button(action: {
        Task {
          try? await authService.deleteUser()
        }
      }) {
        Text(authService.string.deleteAccountButtonLabel)
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity)
      }
      .padding([.top, .bottom], 8)
      .frame(maxWidth: .infinity)
      .buttonStyle(.borderedProminent)
    }
    .safeAreaPadding()
    .sheet(isPresented: isShowingPasswordPrompt) {
      PasswordPromptSheet(coordinator: authService.passwordPrompt)
    }
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  return SignedInView()
    .environment(AuthService())
}
