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

import FirebaseCore
import SwiftUI

public struct VerifyEmailView {
  @Environment(AuthService.self) private var authService
  @State private var showModal = false

  private func sendEmailVerification() async {
    do {
      try await authService.sendEmailVerification()
      showModal = true
    } catch {
      // Error already displayed via modal by AuthService
    }
  }
}

extension VerifyEmailView: View {
  public var body: some View {
    VStack {
      Button(action: {
        Task {
          await sendEmailVerification()
        }
      }) {
        Text(authService.string.sendEmailVerificationButtonLabel)
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity)
      }
      .padding([.top, .bottom, .horizontal], 8)
      .frame(maxWidth: .infinity)
      .buttonStyle(.borderedProminent)
    }.sheet(isPresented: $showModal) {
      VStack {
        Text(authService.string.verifyEmailSheetMessage)
          .font(.headline)
        Button(authService.string.okButtonLabel) {
          showModal = false
        }
        .padding()
      }
      .padding()
    }
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  return VerifyEmailView()
    .environment(AuthService())
}
