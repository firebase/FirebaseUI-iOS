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
@MainActor
public struct AuthPickerView<Content: View>: View {
  public init(@ViewBuilder content: @escaping () -> Content = { EmptyView() }) {
    self.content = content
  }

  private let content: () -> Content

  public var body: some View {
    AuthPickerContent(
      content: content,
      pickerContent: { DefaultAuthPickerContent() },
      destination: { DefaultAuthPickerDestination(screen: $0) }
    )
  }

  /// Replaces the first screen of the authentication sheet.
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
      pickerContent: pickerContent,
      destination: { DefaultAuthPickerDestination(screen: $0) }
    )
  }

  /// Replaces the screens pushed inside the authentication sheet. Return
  /// ``DefaultAuthPickerDestination`` for routes you don't customize.
  ///
  /// ```swift
  /// AuthPickerView { authenticatedApp }
  ///   .pickerDestination { screen in
  ///     DefaultAuthPickerDestination(screen: screen)
  ///       .background(theme.colors.background)
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
      pickerContent: { DefaultAuthPickerContent() },
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
