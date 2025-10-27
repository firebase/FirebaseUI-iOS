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

struct EmailSignUpView: View {
  let state: EmailAuthContentState
  
  var body: some View {
    VStack(spacing: 32) {
      VStack(spacing: 16) {
        Group {
          AuthTextField(
            text: state.displayName,
            localizedTitle: "Display Name",
            prompt: "Enter your name",
            contentType: .name
          )
          
          AuthTextField(
            text: state.email,
            localizedTitle: "Email",
            prompt: "Enter your email",
            keyboardType: .emailAddress,
            contentType: .emailAddress
          )
          
          AuthTextField(
            text: state.password,
            localizedTitle: "Password",
            prompt: "Enter your password",
            contentType: .newPassword,
            sensitive: true
          )
          
          AuthTextField(
            text: state.confirmPassword,
            localizedTitle: "Confirm Password",
            prompt: "Re-enter your password",
            contentType: .newPassword,
            sensitive: true
          )
        }
        
        Button {
          state.onSignUpClick()
        } label: {
          if state.isLoading {
            ProgressView()
              .frame(height: 32)
              .frame(maxWidth: .infinity)
          } else {
            Text("Create Account")
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
    .navigationTitle("Create an account")
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
  }
}

#Preview {
  NavigationStack {
    EmailSignUpView(state: EmailAuthContentState(
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
