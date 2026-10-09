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

import FirebaseAuthUIComponents
import SwiftUI

/// The default signed-out first screen of the authentication sheet: the logo, email sign-in,
/// the provider buttons and the terms.
///
/// Return it from ``AuthPickerView/pickerContent(_:)`` to keep the stock screen while adding
/// modifiers such as a background.
@MainActor
public struct DefaultAuthPickerContent<AuthMethodPicker: View>: View {
  public init() where AuthMethodPicker == DefaultAuthMethodPicker {
    authMethodPicker = { DefaultAuthMethodPicker() }
  }

  @Environment(AuthService.self) private var authService
  private let authMethodPicker: () -> AuthMethodPicker

  public var body: some View {
    GeometryReader { proxy in
      ScrollView {
        VStack(spacing: 24) {
          Image(authService.configuration.logo ?? Assets.firebaseAuthLogo)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 100)
          if authService.emailPasswordSignInEnabled {
            EmailAuthView()
          }
          Divider()
          authMethodPicker()
            .padding(.horizontal, proxy.size.width * 0.14)
          PrivacyTOCsView(displayMode: .full)
        }
      }
    }
    .safeAreaPadding()
  }
}

/// The default provider list on ``DefaultAuthPickerContent``: every registered provider's
/// button, stacked vertically.
@MainActor
public struct DefaultAuthMethodPicker: View {
  public init() {}

  @Environment(AuthService.self) private var authService

  public var body: some View {
    VStack {
      authService.renderButtons()
    }
  }
}
