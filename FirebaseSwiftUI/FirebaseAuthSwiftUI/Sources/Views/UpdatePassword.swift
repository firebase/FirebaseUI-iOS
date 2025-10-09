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
//  UpdatePassword.swift
//  FirebaseUI
//
//  Created by Russell Wheatley on 24/04/2025.
//

import FirebaseCore
import SwiftUI

private enum FocusableField: Hashable {
  case password
  case confirmPassword
}

@MainActor
public struct UpdatePasswordView {
  @Environment(AuthService.self) private var authService
  @State private var password = ""
  @State private var confirmPassword = ""

  @FocusState private var focus: FocusableField?
  private var isValid: Bool {
    !password.isEmpty && password == confirmPassword
  }
}

extension UpdatePasswordView: View {
  private var isShowingPasswordPrompt: Binding<Bool> {
    Binding(
      get: { authService.passwordPrompt.isPromptingPassword },
      set: { authService.passwordPrompt.isPromptingPassword = $0 }
    )
  }

  public var body: some View {
    VStack {
      HStack {
        Button(action: {
          authService.authView = .authPicker
        }) {
          HStack(spacing: 4) {
            Image(systemName: "chevron.left")
              .font(.system(size: 17, weight: .medium))
            Text(authService.string.backButtonLabel)
              .font(.system(size: 17))
          }
          .foregroundColor(.blue)
        }
        .accessibilityIdentifier("update-password-back-button")

        Spacer()
      }
      .padding(.horizontal)
      .padding(.top, 8)
      LabeledContent {
        SecureField(authService.string.passwordInputLabel, text: $password)
          .focused($focus, equals: .password)
          .submitLabel(.go)
      } label: {
        Image(systemName: "lock")
      }
      .padding(.vertical, 6)
      .background(Divider(), alignment: .bottom)
      .padding(.bottom, 8)

      Divider()

      LabeledContent {
        SecureField(authService.string.confirmPasswordInputLabel, text: $confirmPassword)
          .focused($focus, equals: .confirmPassword)
          .submitLabel(.go)
      } label: {
        Image(systemName: "lock")
      }
      .padding(.vertical, 6)
      .background(Divider(), alignment: .bottom)
      .padding(.bottom, 8)

      Divider()

      Button(action: {
        Task {
          try await authService.updatePassword(to: confirmPassword)
          authService.authView = .authPicker
        }
      }, label: {
        Text(authService.string.updatePasswordButtonLabel)
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity)

      })
      .disabled(!isValid)
      .padding([.top, .bottom], 8)
      .frame(maxWidth: .infinity)
      .buttonStyle(.borderedProminent)
    }.sheet(isPresented: isShowingPasswordPrompt) {
      PasswordPromptSheet(coordinator: authService.passwordPrompt)
    }
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  return UpdatePasswordView()
    .environment(AuthService())
}
