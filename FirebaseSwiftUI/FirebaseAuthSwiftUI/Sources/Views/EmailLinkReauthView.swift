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
import FirebaseCore
import SwiftUI

@MainActor
public struct EmailLinkReauthView {
  @Environment(AuthService.self) private var authService
  @Environment(\.reportError) private var reportError

  let email: String
  let coordinator: ReauthenticationCoordinator

  @State private var emailSent = false
  @State private var isLoading = false
  @State private var error: AlertError?

  private func sendEmailLink() async {
    isLoading = true
    do {
      try await authService.sendEmailSignInLink(email: email, isReauth: true)
      emailSent = true
      isLoading = false
    } catch {
      if let reportError = reportError {
        reportError(error)
      } else {
        self.error = AlertError(
          title: "Error",
          message: error.localizedDescription,
          underlyingError: error
        )
      }
      isLoading = false
    }
  }

  private func handleReauthURL(_ url: URL) {
    Task { @MainActor in
      do {
        try await authService.handleSignInLink(url: url)
        coordinator.reauthCompleted()
      } catch {
        if let reportError = reportError {
          reportError(error)
        } else {
          self.error = AlertError(
            title: "Error",
            message: error.localizedDescription,
            underlyingError: error
          )
        }
      }
    }
  }
}

extension EmailLinkReauthView: View {
  public var body: some View {
    NavigationStack {
      VStack(spacing: 24) {
        if emailSent {
          // "Check your email" state
          VStack(spacing: 16) {
            Image(systemName: "envelope.open.fill")
              .font(.system(size: 60))
              .foregroundColor(.accentColor)
              .padding(.top, 32)

            Text("Check Your Email")
              .font(.title)
              .fontWeight(.bold)

            Text("We've sent a verification link to:")
              .font(.body)
              .foregroundStyle(.secondary)

            Text(email)
              .font(.body)
              .fontWeight(.medium)
              .padding(.horizontal)

            Text("Tap the link in the email to complete reauthentication.")
              .font(.body)
              .multilineTextAlignment(.center)
              .foregroundStyle(.secondary)
              .padding(.horizontal, 32)
              .padding(.top, 8)

            Button {
              Task {
                await sendEmailLink()
              }
            } label: {
              if isLoading {
                ProgressView()
                  .frame(height: 32)
              } else {
                Text("Resend Email")
                  .frame(height: 32)
              }
            }
            .buttonStyle(.bordered)
            .disabled(isLoading)
            .padding(.top, 16)
          }
        } else {
          // Loading/sending state
          VStack(spacing: 16) {
            ProgressView()
              .padding(.top, 32)
            Text("Sending verification email...")
              .foregroundStyle(.secondary)
          }
        }

        Spacer()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      .navigationTitle("Verify Your Identity")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            coordinator.reauthCancelled()
          }
        }
      }
      .onOpenURL { url in
        handleReauthURL(url)
      }
      .task {
        await sendEmailLink()
      }
    }
    .errorAlert(error: $error, okButtonLabel: authService.string.okButtonLabel)
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  return EmailLinkReauthView(
    email: "test@example.com",
    coordinator: ReauthenticationCoordinator()
  )
  .environment(AuthService())
}
