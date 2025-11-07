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

import FirebaseAuthUIComponents
import FirebaseCore
import SwiftUI

struct PasswordPromptSheet {
  @Environment(AuthService.self) private var authService
  @Bindable var coordinator: PasswordPromptCoordinator
  @State private var password = ""
}

extension PasswordPromptSheet: View {
  var body: some View {
    VStack(spacing: 20) {
      Text(authService.string.confirmPasswordInputLabel)
        .font(.largeTitle)
        .fontWeight(.bold)
        .padding()

      Divider()

      AuthTextField(
        text: $password,
        label: authService.string.passwordFieldLabel,
        prompt: authService.string.passwordInputLabel,
        contentType: .password,
        isSecureTextField: true,
        onSubmit: { _ in
          if !password.isEmpty {
            coordinator.submit(password: password)
          }
        },
        leading: {
          Image(systemName: "lock")
        }
      )
      .submitLabel(.next)

      Button(action: {
        coordinator.submit(password: password)
      }) {
        Text(authService.string.okButtonLabel)
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity)
      }
      .disabled(password.isEmpty)
      .padding([.top, .bottom, .horizontal], 8)
      .frame(maxWidth: .infinity)
      .buttonStyle(.borderedProminent)

      Button(authService.string.cancelButtonLabel) {
        coordinator.cancel()
      }
    }
    .padding()
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  return PasswordPromptSheet(coordinator: PasswordPromptCoordinator()).environment(AuthService())
}
