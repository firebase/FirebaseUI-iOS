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

import FirebaseAuth
import FirebaseAuthSwiftUI
import FirebaseCore
import SwiftUI

@MainActor
public struct PhoneAuthView {
  @Environment(\.dismiss) private var dismiss
  @State private var currentError: AlertError?
  @State private var phoneNumber = ""
  @State private var showVerificationCodeInput = false
  @State private var verificationCode = ""
  @State private var verificationID = ""
  @State private var isProcessing = false
  let phoneProvider: PhoneAuthProviderSwift
  let completion: (Result<(String, String), Error>) -> Void

  public init(phoneProvider: PhoneAuthProviderSwift,
              completion: @escaping (Result<(String, String), Error>) -> Void) {
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
            completion(.failure(AuthServiceError
                .signInCancelled("User cancelled sign-in for Phone")))
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
            TextField("Enter phone number", text: $phoneNumber)
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

          Button(action: {
            Task {
              isProcessing = true
              do {
                let id = try await phoneProvider.verifyPhoneNumber(phoneNumber: phoneNumber)
                verificationID = id
                showVerificationCodeInput = true
                currentError = nil
              } catch {
                currentError = AlertError(message: error.localizedDescription)
              }
              isProcessing = false
            }
          }) {
            Text("Send Code")
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

          TextField("Verification Code", text: $verificationCode)
            .keyboardType(.numberPad)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .padding(.horizontal)

          Button(action: {
            Task {
              isProcessing = true
              // Return the verification details to createAuthCredential
              completion(.success((verificationID, verificationCode)))
              showVerificationCodeInput = false
              dismiss()
            }
          }) {
            Text("Verify and Sign In")
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
    .errorAlert(error: $currentError, okButtonLabel: "OK")
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  let phoneProvider = PhoneProviderSwift()
  return PhoneAuthView(phoneProvider: phoneProvider) { result in
    switch result {
    case let .success(verificationID, verificationCode):
      print("Preview: Got verification - ID: \(verificationID), Code: \(verificationCode)")
    case let .failure(error):
      print("Preview: Phone auth failed with error: \(error)")
    }
  }
}
