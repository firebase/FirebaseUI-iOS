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

import SwiftUI

struct PasswordPromptSheet {
  @Environment(AuthService.self) private var authService
  @Bindable var coordinator: PasswordPromptCoordinator
  @State private var password = ""
}

extension PasswordPromptSheet: View {
  var body: some View {
    VStack(spacing: 20) {
      SecureField(authService.string.passwordInputLabel, text: $password)
        .textFieldStyle(.roundedBorder)
        .padding()

      HStack {
        Button(authService.string.cancelButtonLabel) {
          coordinator.cancel()
        }
        Spacer()
        Button(authService.string.okButtonLabel) {
          coordinator.submit(password: password)
        }
        .disabled(password.isEmpty)
      }
      .padding(.horizontal)
    }
    .padding()
  }
}

#Preview {
  PasswordPromptSheet(coordinator: PasswordPromptCoordinator())
}
