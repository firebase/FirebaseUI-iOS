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
import FirebaseAuthUIComponents

struct EnterVerificationCodeView: View {
  let state: PhoneAuthContentState
  
  var body: some View {
    VStack(spacing: 32) {
      VStack(spacing: 16) {
        VStack(spacing: 8) {
          Text("We sent a code to \(state.fullPhoneNumber)")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .leading)
          Button {
            state.onChangeNumberClick()
          } label: {
            Text("Change number")
              .font(.caption)
              .frame(maxWidth: .infinity, alignment: .leading)
          }
        }
        .padding(.bottom)
        .frame(maxWidth: .infinity, alignment: .leading)
        
        // Verification code input
        VerificationCodeInputField(
          code: state.verificationCode,
          isError: state.error != nil,
          errorMessage: state.error
        )
        
        Button {
          state.onVerifyCodeClick()
        } label: {
          if state.isLoading {
            ProgressView()
              .frame(height: 32)
              .frame(maxWidth: .infinity)
          } else {
            Text("Verify Code")
              .frame(height: 32)
              .frame(maxWidth: .infinity)
          }
        }
        .buttonStyle(.borderedProminent)
        .disabled(state.isLoading || state.verificationCode.wrappedValue.count != 6)
      }
      
      // Resend code section
      VStack(spacing: 8) {
        if state.resendTimer > 0 {
          Text("Resend code in \(state.resendTimer)s")
            .font(.caption)
            .foregroundStyle(.secondary)
        } else {
          Button {
            state.onResendCodeClick()
          } label: {
            Text("Resend Code")
              .font(.caption)
          }
          .disabled(state.isLoading)
        }
      }
    }
    .navigationTitle("Verify Phone Number")
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
  }
}

#Preview {
  NavigationStack {
    EnterVerificationCodeView(state: PhoneAuthContentState(
      isLoading: false,
      error: nil,
      phoneNumber: .constant(""),
      selectedCountry: .constant(.default),
      verificationCode: .constant(""),
      fullPhoneNumber: "+1 5551234567",
      resendTimer: 0,
      onSendCodeClick: {},
      onVerifyCodeClick: {},
      onResendCodeClick: {},
      onChangeNumberClick: {}
    ))
    .safeAreaPadding()
  }
}
