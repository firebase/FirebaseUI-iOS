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

/// The default content shown inside the ``AuthPickerView`` sheet: the sign-in method picker
/// (or ``SignedInView`` when already authenticated), plus the authenticating overlay.
///
/// Use this together with ``AuthPickerView/pickerContent(_:)`` to customize its appearance
/// (background, tint, etc.) with plain SwiftUI modifiers, without rebuilding the auth UI from
/// scratch:
///
/// ```swift
/// AuthPickerView { authenticatedApp }
///   .pickerContent {
///     AuthPickerContentView()
///       .background(theme.colors.background)
///   }
/// ```
///
/// To customize the *layout* of the sign-in-method list itself (e.g. a grid of icon-only
/// buttons instead of the default stacked list), pass an `authMethodPicker` builder. It receives
/// the registered providers and a callback to invoke when one is selected — pair it with
/// `AuthService.triggerSignIn(for:)` if you build your own buttons, or use `onProviderSelected`
/// directly:
///
/// ```swift
/// AuthPickerContentView { providers, onProviderSelected in
///   LazyVGrid(columns: [GridItem(), GridItem()]) {
///     ForEach(providers, id: \.id) { provider in
///       Button(provider.displayName) { onProviderSelected(provider) }
///     }
///   }
/// }
/// ```
@MainActor
public struct AuthPickerContentView<AuthMethodPicker: View>: View {
  @Environment(AuthService.self) private var authService
  @Environment(\.mfaHandler) private var mfaHandler
  @Environment(\.accountConflictHandler) private var accountConflictHandler
  @Environment(\.reportError) private var reportError

  private let authMethodPicker: ([AuthProviderUI], @escaping (AuthProviderUI) -> Void) -> AuthMethodPicker

  public init() where AuthMethodPicker == DefaultProviderButtonsLayout {
    authMethodPicker = { providers, onSelect in
      DefaultProviderButtonsLayout(providers: providers, onSelect: onSelect)
    }
  }

  public init(
    @ViewBuilder authMethodPicker: @escaping (
      [AuthProviderUI],
      @escaping (AuthProviderUI) -> Void
    ) -> AuthMethodPicker
  ) {
    self.authMethodPicker = authMethodPicker
  }

  public var body: some View {
    @Bindable var authService = authService
    VStack {
      if authService.authenticationState == .authenticated {
        SignedInView()
      } else {
        methodPickerScreen
          .safeAreaPadding()
      }
    }
    .overlay {
      if authService.authenticationState == .authenticating {
        VStack(spacing: 24) {
          ProgressView()
            .scaleEffect(1.25)
            .tint(.white)
          Text("Authenticating...")
            .authFont(.body)
            .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black.opacity(0.7))
      }
    }
  }

  @ViewBuilder
  private var methodPickerScreen: some View {
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
        authMethodPicker(authService.registeredProviders, handleProviderSelected)
        PrivacyTOCsView(displayMode: .full)
      }
    }
  }

  /// Signs in with `provider` via `AuthService.triggerSignIn(for:)`, then handles the same
  /// MFA/account-conflict/error cases each provider's own default button already handles inline
  /// (e.g. `GenericOAuthButton`) — so a custom `authMethodPicker` layout behaves equivalently to
  /// the default one.
  private func handleProviderSelected(_ provider: AuthProviderUI) {
    Task {
      do {
        if let outcome = try await authService.triggerSignIn(for: provider),
           case let .mfaRequired(mfaInfo) = outcome,
           let onMFA = mfaHandler {
          onMFA(mfaInfo)
        }
      } catch {
        if case let AuthServiceError.accountConflict(ctx) = error,
           let onConflict = accountConflictHandler {
          onConflict(ctx)
          return
        }
        reportError?(error)
      }
    }
  }
}

/// The default sign-in-method list layout: a `VStack` of each registered provider's own button
/// view, unchanged from what `AuthPickerContentView` has always shown. Uses
/// `.containerRelativeFrame(_:alignment:_:)` to reproduce the original
/// `.padding(.horizontal, proxy.size.width * 0.14)` behavior (72% of the container's width,
/// centered) without needing a `GeometryReader` — which would otherwise have to be exposed
/// through `authMethodPicker`'s signature just for this one layout's benefit, or nested inside
/// the `ScrollView`'s content where `GeometryReader`'s unbounded-height proposal causes sizing
/// bugs.
public struct DefaultProviderButtonsLayout: View {
  @Environment(AuthService.self) private var authService
  let providers: [AuthProviderUI]
  let onSelect: (AuthProviderUI) -> Void

  public var body: some View {
    VStack {
      authService.renderButtons()
    }
    .containerRelativeFrame(.horizontal) { length, _ in length * 0.72 }
  }
}
