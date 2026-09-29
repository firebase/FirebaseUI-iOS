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
import SwiftUI

/// An ``AuthPickerView`` with custom sheet content, returned by
/// ``AuthPickerView/pickerContent(_:)`` and ``AuthPickerView/pickerDestination(_:)``.
///
/// It owns the authentication sheet, its `NavigationStack`, error alerts, and MFA and
/// account-conflict handling; only the first screen and the pushed screens come from the slots.
/// You don't create it directly.
@MainActor
public struct AuthPickerContent<
  Content: View,
  PickerContent: View,
  DestinationContent: View
>: View {
  init(content: @escaping () -> Content,
       pickerContent: @escaping () -> PickerContent,
       destination: @escaping (AuthView) -> DestinationContent) {
    self.content = content
    self.pickerContent = pickerContent
    self.destination = destination
  }

  @Environment(AuthService.self) private var authService
  private let content: () -> Content
  private let pickerContent: () -> PickerContent
  private let destination: (AuthView) -> DestinationContent

  // View-layer error state
  @State private var error: AlertError?

  public var body: some View {
    @Bindable var authService = authService
    content()
      .sheet(isPresented: $authService.isPresented) {
        @Bindable var navigator = authService.navigator
        NavigationStack(path: $navigator.routes) {
          pickerContent()
            .navigationTitle(authService.authenticationState == .unauthenticated ? authService
              .string.authPickerTitle : "")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
              toolbar
            }
            .navigationDestination(for: AuthView.self) { view in
              destination(view)
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
        .environment(authService)
      }
  }

  /// Replaces the first screen of the authentication sheet.
  public func pickerContent<NewPickerContent: View>(
    @ViewBuilder _ pickerContent: @escaping () -> NewPickerContent
  ) -> AuthPickerContent<Content, NewPickerContent, DestinationContent> {
    AuthPickerContent<Content, NewPickerContent, DestinationContent>(
      content: content,
      pickerContent: pickerContent,
      destination: destination
    )
  }

  /// Replaces the screens pushed inside the authentication sheet.
  public func pickerDestination<NewDestinationContent: View>(
    @ViewBuilder _ destination: @escaping (AuthView) -> NewDestinationContent
  ) -> AuthPickerContent<Content, PickerContent, NewDestinationContent> {
    AuthPickerContent<Content, PickerContent, NewDestinationContent>(
      content: content,
      pickerContent: pickerContent,
      destination: destination
    )
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
  private var toolbar: some ToolbarContent {
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
