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

import FirebaseAuth
import FirebaseAuthUIComponents
import FirebaseCore
import SwiftUI

@MainActor
public struct AccountLinkingView {
  @Environment(AuthService.self) private var authService
  @Environment(\.dismiss) private var dismiss

  let context: AccountMergeConflictContext

  public init(context: AccountMergeConflictContext) {
    self.context = context
  }
}

extension AccountLinkingView: View {
  public var body: some View {
    VStack(spacing: 24) {
      // Warning icon
      Image(systemName: "exclamationmark.triangle.fill")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 60, height: 60)
        .foregroundColor(.orange)

      // Title
      Text("Account Already Exists")
        .font(.title2)
        .fontWeight(.bold)

      // Message
      Text(
        "An account with **\(context.email ?? "this email")** already exists. Please sign in with your existing authentication method below to link your accounts."
      )
      .multilineTextAlignment(.center)
      .fixedSize(horizontal: false, vertical: true)

      Divider()

      // Sign in methods section
      VStack(spacing: 16) {
        Text("Sign in with your existing method:")
          .font(.headline)

        if authService.emailSignInEnabled {
          EmailAuthView()
            .environment(\.signInWithMergeConflictHandler, signInForAccountLinking)
        }

        // Show other provider buttons
        authService.renderButtons()
          .environment(\.signInWithMergeConflictHandler, signInForAccountLinking)
      }

      PrivacyTOCsView(displayMode: .full)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .safeAreaPadding()
    .navigationTitle("Link Accounts")
    .navigationBarTitleDisplayMode(.inline)
  }

  /// Custom sign-in handler for account linking flow
  private func signInForAccountLinking(authService: AuthService,
                                       signInAction: () async throws -> SignInOutcome) async throws
    -> SignInOutcome {
    do {
      // Attempt to sign in with the existing provider
      let outcome = try await signInAction()

      // If successful, link the pending credential
      if case .signedIn = outcome {
        try await authService.linkAccounts(credentials: context.credential)
        // Dismiss the sheet after successful linking
        dismiss()
      }

      return outcome
    } catch {
      // Re-throw the error for normal error handling
      throw error
    }
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  let authService = AuthService().withEmailSignIn()

  let context = AccountMergeConflictContext(
    credential: EmailAuthProvider.credential(
      withEmail: "user@example.com",
      password: "password"
    ),
    underlyingError: NSError(domain: "Test", code: 0),
    message: "Test error",
    uid: nil,
    email: "user@example.com",
    requiresManualLinking: true
  )

  return NavigationStack {
    AccountLinkingView(context: context)
      .environment(authService)
  }
}
