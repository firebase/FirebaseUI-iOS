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

//
//  PhoneAuthView.swift
//  FirebaseUI
//
//  Created by Russell Wheatley on 14/05/2025.
//

import FirebaseAuthSwiftUI
import FirebaseCore
import FirebaseAuth
import SwiftUI

@MainActor
public struct PhoneAuthView {
  @Environment(AuthService.self) private var authService
  @Environment(\.dismiss) private var dismiss
  @State private var errorMessage = ""
  @State private var phoneNumber = ""
  @State private var showVerificationCodeInput = false
  @State private var verificationCode = ""
  @State private var verificationID = ""
  @State private var isProcessing = false
  let phoneProvider: PhoneAuthProviderSwift
  let completion: (Result<AuthCredential, Error>) -> Void

  public init(phoneProvider: PhoneAuthProviderSwift, completion: @escaping (Result<AuthCredential, Error>) -> Void) {
    self.phoneProvider = phoneProvider
    self.completion = completion
  }
}

extension PhoneAuthView: View {
  public var body: some View {
    ZStack {
      VStack(spacing: 16) {
        // Header with cancel button
        HStack {
          Spacer()
          Button(action: {
            completion(.failure(NSError(domain: "PhoneAuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User cancelled"])))
            dismiss()
          }) {
            Image(systemName: "xmark.circle.fill")
              .font(.title2)
              .foregroundColor(.gray)
          }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        
        if !isProcessing {
          Text("Sign in with Phone")
            .font(.title2)
            .bold()
          
          LabeledContent {
            TextField(authService.string.enterPhoneNumberLabel, text: $phoneNumber)
              .textInputAutocapitalization(.never)
              .disableAutocorrection(true)
              .submitLabel(.next)
              .keyboardType(.phonePad)
          } label: {
            Image(systemName: "phone.fill")
          }
          .padding(.vertical, 6)
          .background(Divider(), alignment: .bottom)
          .padding(.bottom, 4)
          .padding(.horizontal)
          
          if !errorMessage.isEmpty {
            Text(errorMessage)
              .foregroundColor(.red)
              .font(.caption)
              .padding(.horizontal)
          }
          
          Button(action: {
            Task {
              isProcessing = true
              do {
                let id = try await phoneProvider.verifyPhoneNumber(phoneNumber: phoneNumber)
                verificationID = id
                showVerificationCodeInput = true
                errorMessage = ""
              } catch {
                errorMessage = authService.string.localizedErrorMessage(
                for: error
              )
              }
              isProcessing = false
            }
          }) {
            Text(authService.string.smsCodeSendButtonLabel)
              .padding(.vertical, 8)
              .frame(maxWidth: .infinity)
          }
          .disabled(!PhoneUtils.isValidPhoneNumber(phoneNumber) || isProcessing)
          .padding([.top, .bottom], 8)
          .padding(.horizontal)
          .buttonStyle(.borderedProminent)
          
          Spacer()
        } else {
          Spacer()
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
            .padding()
          Text("Processing...")
            .foregroundColor(.secondary)
          Spacer()
        }
      }
      .sheet(isPresented: $showVerificationCodeInput) {
        VStack(spacing: 16) {
          // Header with cancel button
          HStack {
            Spacer()
            Button(action: {
              showVerificationCodeInput = false
            }) {
              Image(systemName: "xmark.circle.fill")
                .font(.title2)
                .foregroundColor(.gray)
            }
          }
          .padding(.horizontal)
          .padding(.top, 8)
          
          Text("Enter Verification Code")
            .font(.title2)
            .bold()
          
          TextField(authService.string.phoneNumberVerificationCodeLabel, text: $verificationCode)
            .keyboardType(.numberPad)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .padding(.horizontal)
          
          if !errorMessage.isEmpty {
            Text(errorMessage)
              .foregroundColor(.red)
              .font(.caption)
              .padding(.horizontal)
          }
          
          Button(action: {
            Task {
              isProcessing = true
              do {
                guard let phoneAuthProvider = phoneProvider as? PhoneProviderSwift else {
                  errorMessage = "Invalid phone provider"
                  isProcessing = false
                  return
                }
                let credential = phoneAuthProvider.createPhoneAuthCredential(
                  verificationID: verificationID,
                  verificationCode: verificationCode
                )
                completion(.success(credential))
                showVerificationCodeInput = false
                dismiss()
              } catch {
                errorMessage = error.localizedDescription
                isProcessing = false
              }
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
          .disabled(verificationCode.isEmpty || isProcessing)
          
          Spacer()
        }
        .padding(.vertical)
      }
    }
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  let phoneProvider = PhoneProviderSwift()
  return PhoneAuthView(phoneProvider: phoneProvider) { result in
    switch result {
    case .success:
      print("Preview: Phone auth succeeded")
    case .failure(let error):
      print("Preview: Phone auth failed with error: \(error)")
    }
  }
}
