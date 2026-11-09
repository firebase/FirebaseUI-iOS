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
import SwiftUI

/// An ``AuthPickerView`` with custom sheet content, returned by
/// `AuthPickerView`'s `pickerContent` and ``AuthPickerView/pickerDestination(_:)`` modifiers.
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
       pickerContent: @escaping (AuthMethodPickerState) -> PickerContent,
       destination: @escaping (AuthView) -> DestinationContent,
       showsPickerTitle: Bool = true) {
    self.content = content
    self.pickerContent = pickerContent
    self.destination = destination
    self.showsPickerTitle = showsPickerTitle
  }

  @Environment(AuthService.self) private var authService
  private let content: () -> Content
  private let pickerContent: (AuthMethodPickerState) -> PickerContent
  private let destination: (AuthView) -> DestinationContent
  /// `false` when the whole first screen is custom, so the library's large title doesn't sit
  /// above the app's own heading. The close button stays so the sheet can still be dismissed.
  private let showsPickerTitle: Bool

  // View-layer error state
  @State private var error: AlertError?

  public var body: some View {
    @Bindable var authService = authService
    content()
      // Reopening the sheet starts from the first screen, not a half-finished pushed one.
      .sheet(isPresented: $authService.isPresented, onDismiss: authService.navigator.clear) {
        @Bindable var navigator = authService.navigator
        NavigationStack(path: $navigator.routes) {
          root
            .navigationTitle(
              showsPickerTitle && authService.authenticationState == .unauthenticated
                ? authService.string.authPickerTitle : ""
            )
            .navigationBarTitleDisplayMode(showsPickerTitle ? .large : .inline)
            .toolbar {
              toolbar
            }
            .navigationDestination(for: AuthView.self) { view in
              destination(view)
                // Pushed screens inherit an `.automatic` title mode from the root. Keep them
                // large when the root is inline because a custom first screen hid its title.
                .navigationBarTitleDisplayMode(showsPickerTitle ? .automatic : .large)
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
        // Close pushed email screens however the user got signed in, including account
        // conflicts the library resolves by signing in for them.
        .onChange(of: authService.authenticationState) { _, state in
          if state == .authenticated {
            authService.navigator.removeEmailRoutes()
          }
        }
        // Apply account conflict handling at NavigationStack level
        .accountConflictHandler()
        // Apply MFA handling at NavigationStack level
        .mfaHandler()
        .environment(authService)
      }
  }

  /// The sheet's first screen. The slot only replaces the signed-out screen, so signed-in users
  /// always reach ``SignedInView`` and the progress overlay always shows while signing in.
  @ViewBuilder
  private var root: some View {
    VStack {
      if authService.authenticationState == .authenticated {
        SignedInView()
      } else {
        AuthMethodPickerStateReader { state in
          pickerContent(state)
        }
      }
    }
    .overlay {
      if authService.authenticationState == .authenticating {
        VStack(spacing: 24) {
          ProgressView()
            .scaleEffect(1.25)
            .tint(.white)
          Text("Authenticating...")
            .authCustomFont(.body)
            .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black.opacity(0.7))
      }
    }
  }

  /// Replaces the signed-out first screen of the authentication sheet. See
  /// the no-argument `pickerContent` on ``AuthPickerView``.
  public func pickerContent<NewPickerContent: View>(
    @ViewBuilder _ pickerContent: @escaping () -> NewPickerContent
  ) -> AuthPickerContent<Content, NewPickerContent, DestinationContent> {
    AuthPickerContent<Content, NewPickerContent, DestinationContent>(
      content: content,
      pickerContent: { _ in pickerContent() },
      destination: destination,
      showsPickerTitle: true
    )
  }

  /// Replaces the whole signed-out first screen with your own, receiving an
  /// ``AuthMethodPickerState``. See the matching `pickerContent` on ``AuthPickerView``.
  public func pickerContent<NewPickerContent: View>(
    @ViewBuilder _ pickerContent: @escaping (AuthMethodPickerState) -> NewPickerContent
  ) -> AuthPickerContent<Content, NewPickerContent, DestinationContent> {
    AuthPickerContent<Content, NewPickerContent, DestinationContent>(
      content: content,
      pickerContent: pickerContent,
      destination: destination,
      showsPickerTitle: false
    )
  }

  /// Replaces the screens pushed inside the authentication sheet. See
  /// ``AuthPickerView/pickerDestination(_:)``.
  public func pickerDestination<NewDestinationContent: View>(
    @ViewBuilder _ destination: @escaping (AuthView) -> NewDestinationContent
  ) -> AuthPickerContent<Content, PickerContent, NewDestinationContent> {
    AuthPickerContent<Content, PickerContent, NewDestinationContent>(
      content: content,
      pickerContent: pickerContent,
      destination: destination,
      showsPickerTitle: showsPickerTitle
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
