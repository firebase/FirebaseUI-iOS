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

struct EmailResetPasswordView: View {
  let state: EmailAuthContentState
  
  var body: some View {
    VStack(spacing: 32) {
      VStack(spacing: 16) {
        if state.resetLinkSent {
          VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
              .font(.system(size: 48))
              .foregroundStyle(.green)
            
            Text("Password reset link sent!")
              .font(.headline)
            
            Text("Check your email at \(state.email.wrappedValue) for a link to reset your password.")
              .font(.subheadline)
              .foregroundStyle(.secondary)
              .multilineTextAlignment(.center)
          }
          .padding()
        } else {
          VStack(spacing: 16) {
            Text("Enter your email address and we'll send you a link to reset your password.")
              .font(.subheadline)
              .foregroundStyle(.secondary)
              .multilineTextAlignment(.center)
            
            AuthTextField(
              text: state.email,
              localizedTitle: "Email",
              prompt: "Enter your email",
              keyboardType: .emailAddress,
              contentType: .emailAddress
            )
            
            Button {
              state.onSendResetLinkClick()
            } label: {
              if state.isLoading {
                ProgressView()
                  .frame(height: 32)
                  .frame(maxWidth: .infinity)
              } else {
                Text("Send Reset Link")
                  .frame(height: 32)
                  .frame(maxWidth: .infinity)
              }
            }
            .buttonStyle(.borderedProminent)
            .disabled(state.isLoading)
            
            if let error = state.error {
              Text(error)
                .foregroundStyle(.red)
                .font(.caption)
            }
          }
        }
      }
    }
    .navigationTitle("Reset Password")
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
  }
}

#Preview {
  NavigationStack {
    EmailResetPasswordView(state: EmailAuthContentState(
      isLoading: false,
      error: nil,
      email: .constant(""),
      password: .constant(""),
      confirmPassword: .constant(""),
      displayName: .constant(""),
      resetLinkSent: false,
      onSignInClick: {},
      onSignUpClick: {},
      onSendResetLinkClick: {},
      onGoToSignUp: {},
      onGoToSignIn: {},
      onGoToResetPassword: {}
    ))
    .safeAreaPadding()
  }
}
