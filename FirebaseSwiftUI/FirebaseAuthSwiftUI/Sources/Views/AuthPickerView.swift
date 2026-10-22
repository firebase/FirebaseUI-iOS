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
import FirebaseAuthUIComponents
import FirebaseCore
import SwiftUI

/// Wraps your app content and presents the authentication sheet whenever
/// `AuthService.isPresented` is `true`.
///
/// Use ``pickerContent(_:)`` and ``pickerDestination(_:)`` to replace the sheet's first screen or
/// any pushed screen while the library keeps driving navigation, MFA and account conflicts.
///
/// Example:
/// ```swift
/// AuthPickerView {
///   HomeView()
/// }
/// .environment(authService)
/// ```
@MainActor
public struct AuthPickerView<Content: View>: View {
  public init(@ViewBuilder content: @escaping () -> Content = { EmptyView() }) {
    self.content = content
  }

  private let content: () -> Content

  public var body: some View {
    AuthPickerContent(
      content: content,
      pickerContent: { _ in DefaultAuthPickerContent() },
      destination: { DefaultAuthPickerDestination(screen: $0) }
    )
  }

  /// Replaces the signed-out first screen of the authentication sheet. The library still shows
  /// ``SignedInView`` to signed-in users and its progress overlay while signing in.
  ///
  /// ```swift
  /// AuthPickerView { authenticatedApp }
  ///   .pickerContent {
  ///     DefaultAuthPickerContent()
  ///       .background(theme.colors.background)
  ///   }
  /// ```
  public func pickerContent<NewPickerContent: View>(
    @ViewBuilder _ pickerContent: @escaping () -> NewPickerContent
  ) -> AuthPickerContent<Content, NewPickerContent, DefaultAuthPickerDestination> {
    AuthPickerContent(
      content: content,
      pickerContent: { _ in pickerContent() },
      destination: { DefaultAuthPickerDestination(screen: $0) }
    )
  }

  /// Replaces the whole signed-out first screen with your own, receiving an
  /// ``AuthMethodPickerState`` to sign in with the registered providers. Call its `select` so MFA,
  /// account conflicts and errors are handled the same as the default buttons.
  ///
  /// Your screen replaces the logo, email sign-in and terms too, so show your own email entry
  /// (for example ``EmailAuthScreen``) and any legal text you need. To keep the stock screen and
  /// only lay out the provider buttons, use ``DefaultAuthPickerContent/init(authMethodPicker:)``.
  ///
  /// Example:
  /// ```swift
  /// AuthPickerView { authenticatedApp }
  ///   .pickerContent { state in
  ///     MyLandingScreen(state: state)
  ///   }
  /// ```
  public func pickerContent<NewPickerContent: View>(
    @ViewBuilder _ pickerContent: @escaping (AuthMethodPickerState) -> NewPickerContent
  ) -> AuthPickerContent<Content, NewPickerContent, DefaultAuthPickerDestination> {
    AuthPickerContent(
      content: content,
      pickerContent: pickerContent,
      destination: { DefaultAuthPickerDestination(screen: $0) }
    )
  }

  /// Replaces the screens pushed inside the authentication sheet.
  ///
  /// Always end a `switch` over the screen with a `default` branch that returns
  /// ``DefaultAuthPickerDestination``. New ``AuthView`` routes may be added in future releases,
  /// and the `default` branch keeps them working without a code change.
  ///
  /// ```swift
  /// AuthPickerView { authenticatedApp }
  ///   .pickerDestination { screen in
  ///     switch screen {
  ///     case .enterPhoneNumber:
  ///       MyPhoneEntry()
  ///     default:
  ///       DefaultAuthPickerDestination(screen: screen)
  ///     }
  ///   }
  /// ```
  public func pickerDestination<NewDestinationContent: View>(
    @ViewBuilder _ destination: @escaping (AuthView) -> NewDestinationContent
  ) -> AuthPickerContent<
    Content,
    DefaultAuthPickerContent<DefaultAuthMethodPicker>,
    NewDestinationContent
  > {
    AuthPickerContent(
      content: content,
      pickerContent: { _ in DefaultAuthPickerContent() },
      destination: destination
    )
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  let authService = AuthService()
    .withEmailSignIn()
  return AuthPickerView().environment(authService)
}
