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
import FirebaseAuthUIComponents
import FirebaseCore
import SwiftUI

@MainActor
public struct PhoneAuthButtonView {
  @Environment(AuthService.self) private var authService
  let phoneProvider: PhoneAuthProviderSwift

  public init(phoneProvider: PhoneAuthProviderSwift) {
    self.phoneProvider = phoneProvider
  }
}

extension PhoneAuthButtonView: View {
  public var body: some View {
    AuthProviderButton(
      label: authService.string.phoneLoginButtonLabel,
      style: .phone,
      accessibilityId: "sign-in-with-phone-button"
    ) {
      Task {
        try? await authService.signIn(phoneProvider)
      }
    }
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  let phoneProvider = PhoneProviderSwift()
  return PhoneAuthButtonView(phoneProvider: phoneProvider)
    .environment(AuthService())
}
