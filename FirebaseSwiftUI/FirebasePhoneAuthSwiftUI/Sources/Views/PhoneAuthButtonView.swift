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

  public init() {}
}

extension PhoneAuthButtonView: View {
  public var body: some View {
    Button(action: {
      authService.registerModalView(for: .phoneAuth) {
        AnyView(PhoneAuthView().environment(authService))
      }
      authService.presentModal(for: .phoneAuth)
    }) {
      Label("Sign in with Phone", systemImage: "phone.fill")
        .foregroundColor(.white)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.green.opacity(0.8)) // Light green
        .cornerRadius(8)
    }
    .accessibilityIdentifier("sign-in-with-phone-button")
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  return PhoneAuthButtonView()
    .environment(AuthService())
}
