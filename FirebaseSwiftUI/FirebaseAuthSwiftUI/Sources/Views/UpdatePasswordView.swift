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
import FirebaseAuthUIComponents
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
  @State private var showAlert = false

  @FocusState private var focus: FocusableField?

  private var isValid: Bool {
    FormValidators.atLeast6Characters.isValid(input: password) &&
      FormValidators.confirmPassword(password: password).isValid(input: confirmPassword)
  }

  private func updatePassword() {
    Task {
      do {
        try await authService.updatePassword(to: confirmPassword)
        showAlert = true
      } catch {}
    }
  }
}

extension UpdatePasswordView: View {
  public var body: some View {
    @Bindable var passwordPrompt = authService.emailProvider?
      .passwordPrompt ?? PasswordPromptCoordinator()
    VStack(spacing: 24) {
      AuthTextField(
        text: $password,
        label: "Type new password",
        prompt: authService.string.passwordInputLabel,
        contentType: .password,
        isSecureTextField: true,
        validations: [
          FormValidators.atLeast6Characters,
        ],
        maintainsValidationMessage: true,
        leading: {
          Image(systemName: "lock")
        }
      )
      .submitLabel(.go)
      .focused($focus, equals: .password)

      AuthTextField(
        text: $confirmPassword,
        label: "Retype new password",
        prompt: authService.string.confirmPasswordInputLabel,
        contentType: .password,
        isSecureTextField: true,
        validations: [
          FormValidators.confirmPassword(password: password),
        ],
        maintainsValidationMessage: true,
        leading: {
          Image(systemName: "lock")
        }
      )
      .submitLabel(.go)
      .focused($focus, equals: .confirmPassword)

      Button(action: {
        updatePassword()
      }, label: {
        Text(authService.string.updatePasswordButtonLabel)
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity)
      })
      .disabled(!isValid)
      .padding([.top, .bottom], 8)
      .frame(maxWidth: .infinity)
      .buttonStyle(.borderedProminent)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .safeAreaPadding()
    .navigationTitle(authService.string.updatePasswordTitle)
    .alert(
      "Password Updated",
      isPresented: $showAlert
    ) {
      Button(authService.string.okButtonLabel) {
        showAlert = false
        authService.navigator.clear()
      }
    } message: {
      Text("Your password has been successfully updated.")
    }
    .sheet(isPresented: $passwordPrompt.isPromptingPassword) {
      PasswordPromptSheet(coordinator: passwordPrompt)
    }
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  return NavigationStack {
    UpdatePasswordView()
      .environment(AuthService())
  }
}
