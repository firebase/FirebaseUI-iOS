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
import FirebaseCore
import SwiftUI

public struct EmailLinkView {
  @Environment(AuthService.self) private var authService
  @State private var email = ""
  @State private var showModal = false

  public init() {}

  private func sendEmailLink() async {
    do {
      try await authService.sendEmailSignInLink(to: email)
      showModal = true
    } catch {}
  }
}

extension EmailLinkView: View {
  public var body: some View {
    VStack {
      Text(authService.string.signInWithEmailLinkViewTitle)
      LabeledContent {
        TextField(authService.string.emailInputLabel, text: $email)
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
          await sendEmailLink()
          authService.emailLink = email
        }
      }) {
        Text(authService.string.sendEmailLinkButtonLabel)
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity)
      }
      .disabled(!CommonUtils.isValidEmail(email))
      .padding([.top, .bottom], 8)
      .frame(maxWidth: .infinity)
      .buttonStyle(.borderedProminent)
      Text(authService.errorMessage).foregroundColor(.red)
    }.sheet(isPresented: $showModal) {
      VStack {
        Text(authService.string.signInWithEmailLinkViewMessage)
          .padding()
        Button(authService.string.okButtonLabel) {
          showModal = false
        }
        .padding()
      }
      .padding()
    }.onOpenURL { url in
      Task {
        do {
          try await authService.handleSignInLink(url: url)
        } catch {}
      }
    }
    .navigationBarItems(leading: Button(action: {
      authService.authView = .authPicker
    }) {
      Image(systemName: "chevron.left")
        .foregroundColor(.blue)
      Text(authService.string.backButtonLabel)
        .foregroundColor(.blue)
    })
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  return EmailLinkView()
    .environment(AuthService())
}
