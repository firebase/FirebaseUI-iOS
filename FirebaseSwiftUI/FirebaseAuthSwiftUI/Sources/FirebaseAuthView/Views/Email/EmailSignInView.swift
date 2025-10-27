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
import FirebaseAuthSwiftUI

struct EmailSignInView: View {
  let authService: AuthService
  let state: EmailAuthContentState
  
  var body: some View {
    VStack(spacing: 32) {
      VStack(spacing: 16) {
        Group {
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
            contentType: .password,
            sensitive: true
          )
        }
        
        Button {
          state.onGoToResetPassword()
        } label: {
          Text("Forgot password?")
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        
        Button {
          state.onSignInClick()
        } label: {
          if state.isLoading {
            ProgressView()
              .frame(height: 32)
              .frame(maxWidth: .infinity)
          } else {
            Text("Sign in")
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
      
      Button {
        state.onGoToSignUp()
      } label: {
        Text("Create an Account")
          .frame(maxWidth: .infinity)
      }
      .disabled(state.isLoading)
    }
    .navigationTitle("Sign in with email")
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
  }
}

#Preview {
  NavigationStack {
    EmailSignInView(
      authService: AuthService(),
      state: EmailAuthContentState(
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
      )
    )
    .safeAreaPadding()
  }
}
