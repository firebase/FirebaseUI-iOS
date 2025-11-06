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

public struct EmailLinkView {
  @Environment(AuthService.self) private var authService
  @Environment(\.accountConflictHandler) private var accountConflictHandler
  @Environment(\.reportError) private var reportError
  @State private var email = ""
  @State private var showModal = false

  public init() {}

  private func sendEmailLink() async throws {
    do {
      try await authService.sendEmailSignInLink(email: email)
      showModal = true
    } catch {
      if let errorHandler = reportError {
        errorHandler(error)
      } else {
        throw error
      }
    }
  }
}

extension EmailLinkView: View {
  public var body: some View {
    VStack(spacing: 24) {
      AuthTextField(
        text: $email,
        label: authService.string.signInLinkEmailFieldLabel,
        prompt: authService.string.emailInputLabel,
        keyboardType: .emailAddress,
        contentType: .emailAddress,
        leading: {
          Image(systemName: "at")
        }
      )
      Button {
        Task {
          try await sendEmailLink()
          authService.emailLink = email
        }
      } label: {
        Text(authService.string.sendEmailLinkButtonLabel)
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.borderedProminent)
      .disabled(!CommonUtils.isValidEmail(email))
      .padding([.top, .bottom], 8)
      .frame(maxWidth: .infinity)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .navigationTitle(authService.string.signInWithEmailLinkViewTitle)
    .safeAreaPadding()
    .sheet(isPresented: $showModal) {
      VStack(spacing: 24) {
        Text(authService.string.signInWithEmailLinkViewMessage)
          .font(.headline)
        Button {
          showModal = false
        } label: {
          Text(authService.string.okButtonLabel)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .padding([.top, .bottom], 8)
        .frame(maxWidth: .infinity)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      .safeAreaPadding()
      .presentationDetents([.medium])
    }
    .onOpenURL { url in
      Task {
        do {
          try await authService.handleSignInLink(url: url)
        } catch {
          // 1) Always report first, if a reporter exists
          reportError?(error)

          // 2) If it's a conflict and we have a handler, handle it and stop
          if case let AuthServiceError.accountConflict(ctx) = error,
             let onConflict = accountConflictHandler {
            onConflict(ctx)
            return
          }

          throw error
        }
      }
    }
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  return EmailLinkView()
    .environment(AuthService())
}
