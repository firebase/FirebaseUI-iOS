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

struct EnterPhoneNumberView: View {
  let state: PhoneAuthContentState
  
  var body: some View {
    VStack(spacing: 16) {
      Text("Enter your phone number to get started")
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, alignment: .leading)
      
      // Phone number input with country selector
      AuthTextField(
        text: state.phoneNumber,
        localizedTitle: "Phone Number",
        prompt: "Enter your phone number",
        keyboardType: .phonePad,
        contentType: .telephoneNumber,
        onChange: { _ in }
      ) {
        CountrySelector(
          selectedCountry: state.selectedCountry,
          enabled: !state.isLoading
        )
      }
      
      Button {
        state.onSendCodeClick()
      } label: {
        if state.isLoading {
          ProgressView()
            .frame(height: 32)
            .frame(maxWidth: .infinity)
        } else {
          Text("Send Code")
            .frame(height: 32)
            .frame(maxWidth: .infinity)
        }
      }
      .buttonStyle(.borderedProminent)
      .disabled(state.isLoading || state.phoneNumber.wrappedValue.isEmpty)
      
      if let error = state.error {
        Text(error)
          .foregroundStyle(.red)
          .font(.caption)
      }
    }
    .navigationTitle("Sign in with phone")
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
  }
}

#Preview {
  NavigationStack {
    EnterPhoneNumberView(state: PhoneAuthContentState(
      isLoading: false,
      error: nil,
      phoneNumber: .constant(""),
      selectedCountry: .constant(.default),
      verificationCode: .constant(""),
      fullPhoneNumber: "+1 ",
      resendTimer: 0,
      onSendCodeClick: {},
      onVerifyCodeClick: {},
      onResendCodeClick: {},
      onChangeNumberClick: {}
    ))
    .safeAreaPadding()
  }
}
