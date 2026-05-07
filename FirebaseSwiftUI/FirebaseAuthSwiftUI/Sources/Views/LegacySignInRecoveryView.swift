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
struct LegacySignInRecoveryView: View {
  @Environment(AuthService.self) private var authService

  var body: some View {
    Group {
      if let recovery = authService.legacySignInRecovery {
        ScrollView {
          VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 12) {
              Text(authService.string.legacySignInRecoveryTitle)
                .font(.title2.weight(.semibold))
              Text(authService.string.legacySignInRecoveryMessage(email: recovery.email))
                .foregroundStyle(.secondary)
            }

            authService.renderLegacyRecoveryButtons()

            if !recovery.unavailableProviders.isEmpty {
              Text(authService.string.legacySignInRecoveryUnavailableMessage)
                .font(.footnote)
                .foregroundStyle(.secondary)
            }

            Button(authService.string.cancelButtonLabel) {
              authService.dismissLegacySignInRecovery()
            }
            .frame(maxWidth: .infinity)
          }
          .padding(24)
          .frame(maxWidth: .infinity, alignment: .leading)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .accessibilityIdentifier("legacy-sign-in-recovery-view")
      } else {
        EmptyView()
      }
    }
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  let authService = AuthService(
    configuration: AuthConfiguration(legacyFetchSignInWithEmail: true)
  )
  authService.legacySignInRecovery = LegacySignInRecoveryContext(
    email: "user@example.com",
    options: [
      LegacySignInOption(id: "password", displayName: "Continue with email and password"),
      LegacySignInOption(id: "google.com", displayName: "Google"),
    ]
  )
  return LegacySignInRecoveryView()
    .environment(authService)
}
