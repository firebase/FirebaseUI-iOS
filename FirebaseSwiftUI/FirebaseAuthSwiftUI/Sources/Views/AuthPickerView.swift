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

@MainActor
public struct AuthPickerView<Content: View, PickerContent: View, DestinationContent: View> {
  public init(@ViewBuilder content: @escaping () -> Content = { EmptyView() })
    where PickerContent == AuthPickerContentView, DestinationContent == AuthPickerDestinationView {
    self.content = content
    pickerContentOverride = { AuthPickerContentView() }
    pickerDestinationOverride = { AuthPickerDestinationView(screen: $0) }
  }

  fileprivate init(
    content: @escaping () -> Content,
    pickerContentOverride: @escaping () -> PickerContent,
    pickerDestinationOverride: @escaping (AuthView) -> DestinationContent
  ) {
    self.content = content
    self.pickerContentOverride = pickerContentOverride
    self.pickerDestinationOverride = pickerDestinationOverride
  }

  @Environment(AuthService.self) private var authService
  private let content: () -> Content

  // View-layer error state
  @State private var error: AlertError?

  private let pickerContentOverride: () -> PickerContent
  private let pickerDestinationOverride: (AuthView) -> DestinationContent
}

public extension AuthPickerView {
  /// Overrides the content shown inside the auth picker sheet, allowing full customization
  /// (background, tint, etc.) via plain SwiftUI modifiers, without changing how
  /// `AuthPickerView` itself is constructed.
  ///
  /// ```swift
  /// AuthPickerView { authenticatedApp }
  ///   .pickerContent {
  ///     AuthPickerContentView()
  ///       .background(theme.colors.background)
  ///   }
  /// ```
  func pickerContent<NewPickerContent: View>(
    @ViewBuilder _ content: @escaping () -> NewPickerContent
  ) -> AuthPickerView<Content, NewPickerContent, DestinationContent> {
    AuthPickerView<Content, NewPickerContent, DestinationContent>(
      content: self.content,
      pickerContentOverride: content,
      pickerDestinationOverride: pickerDestinationOverride
    )
  }

  /// Overrides the content shown for each destination pushed inside the auth picker sheet
  /// (password recovery, email link, MFA, phone verification, etc.), allowing full
  /// customization via plain SwiftUI modifiers, without changing how `AuthPickerView` itself
  /// is constructed.
  ///
  /// ```swift
  /// AuthPickerView { authenticatedApp }
  ///   .pickerDestination { screen in
  ///     AuthPickerDestinationView(screen: screen)
  ///       .background(theme.colors.background)
  ///   }
  /// ```
  func pickerDestination<NewDestinationContent: View>(
    @ViewBuilder _ content: @escaping (AuthView) -> NewDestinationContent
  ) -> AuthPickerView<Content, PickerContent, NewDestinationContent> {
    AuthPickerView<Content, PickerContent, NewDestinationContent>(
      content: self.content,
      pickerContentOverride: pickerContentOverride,
      pickerDestinationOverride: content
    )
  }
}

extension AuthPickerView: View {
  public var body: some View {
    @Bindable var authService = authService
    content()
      .sheet(isPresented: $authService.isPresented) {
        @Bindable var navigator = authService.navigator
        NavigationStack(path: $navigator.routes) {
          pickerContentOverride()
            .navigationTitle(authService.authenticationState == .unauthenticated ? authService
              .string.authPickerTitle : "")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
              toolbar
            }
            .navigationDestination(for: AuthView.self) { view in
              pickerDestinationOverride(view)
            }
        }
        .environment(\.reportError, reportError)
        .errorAlert(
          error: $error,
          okButtonLabel: authService.string.okButtonLabel
        )
        .sheet(item: $authService.legacySignInRecovery) { _ in
          LegacySignInRecoveryView()
            .environment(authService)
        }
        .interactiveDismissDisabled(authService.configuration.interactiveDismissEnabled)
        // Apply account conflict handling at NavigationStack level
        .accountConflictHandler()
        // Apply MFA handling at NavigationStack level
        .mfaHandler()
      }
  }

  /// Closure for reporting errors from child views
  private func reportError(_ error: Error) {
    Task { @MainActor in
      self.error = AlertError(
        message: authService.string.localizedErrorMessage(for: error),
        underlyingError: error
      )
    }
  }

  @ToolbarContentBuilder
  var toolbar: some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      if !authService.configuration.shouldHideCancelButton {
        Button {
          authService.isPresented = false
        } label: {
          Image(systemName: "xmark")
            .foregroundStyle(Color(UIColor.label))
        }
      }
    }
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  let authService = AuthService()
    .withEmailSignIn()
  return AuthPickerView().environment(authService)
}
