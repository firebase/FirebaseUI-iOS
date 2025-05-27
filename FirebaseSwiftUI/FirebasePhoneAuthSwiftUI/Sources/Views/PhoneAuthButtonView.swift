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

import FirebaseAuthSwiftUI
import FirebaseCore
import SwiftUI

@MainActor
public struct PhoneAuthButtonView {
  @Environment(AuthService.self) private var authService
  @State private var errorMessage = ""
  @State private var phoneNumber = ""
  @State private var showVerificationCodeInput = false
  @State private var verificationCode = ""
  @State private var verificationID = ""

  public init() {}
}

extension PhoneAuthButtonView: View {
  public var body: some View {
    if authService.authenticationState != .authenticating {
      VStack {
        LabeledContent {
          TextField(authService.string.enterPhoneNumberLabel, text: $phoneNumber)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .submitLabel(.next)
        } label: {
          Image(systemName: "at")
        }.padding(.vertical, 6)
          .background(Divider(), alignment: .bottom)
          .padding(.bottom, 4)
        Button(action: {
          Task {
            do {
              let id = try await authService.verifyPhoneNumber(phoneNumber: phoneNumber)
              verificationID = id
              showVerificationCodeInput = true
            } catch {
              errorMessage = authService.string.localizedErrorMessage(
                for: error
              )
            }
          }
        }) {
          Text(authService.string.smsCodeSentLabel)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
        }
        .disabled(!PhoneUtils.isValidPhoneNumber(phoneNumber))
        .padding([.top, .bottom], 8)
        .frame(maxWidth: .infinity)
        .buttonStyle(.borderedProminent)
        Text(errorMessage).foregroundColor(.red)
      }.sheet(isPresented: $showVerificationCodeInput) {
        TextField(authService.string.phoneNumberVerificationCodeLabel, text: $verificationCode)
          .keyboardType(.numberPad)
          .padding()
          .background(Color(.systemGray6))
          .cornerRadius(8)
          .padding(.horizontal)

        Button(action: {
          Task {
            do {
              try await authService.signInWithPhoneNumber(
                verificationID: verificationID,
                verificationCode: verificationCode
              )
            } catch {
              errorMessage = authService.string.localizedErrorMessage(for: error)
            }
            showVerificationCodeInput = false
          }
        }) {
          Text(authService.string.verifyPhoneNumberAndSignInLabel)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.green)
            .cornerRadius(8)
            .padding(.horizontal)
        }
      }.onOpenURL { url in
        authService.auth.canHandle(url)
      }
    } else {
      ProgressView()
        .progressViewStyle(CircularProgressViewStyle(tint: .white))
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
    }
    Text(errorMessage).foregroundColor(.red)
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  return PhoneAuthButtonView()
    .environment(AuthService())
}
