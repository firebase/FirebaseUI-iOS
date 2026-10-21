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

/// The state and actions of the MFA management screen, passed to ``MFAManagementScreen``'s
/// content.
public struct MFAManagementContentState {
  /// Removes the enrolled factor with this `uid`, then updates ``enrolledFactors``. Asks the user
  /// to reauthenticate first when Firebase requires it. Does nothing while ``isLoading`` is
  /// `true`.
  public let unenroll: @MainActor (_ factorUid: String) -> Void

  /// Pushes ``AuthView/mfaEnrollment``.
  public let goToEnrollment: @MainActor () -> Void

  /// Reloads ``enrolledFactors`` from the current user.
  public let refresh: @MainActor () -> Void

  /// The current user's enrolled second factors.
  public let enrolledFactors: [MultiFactorInfo]

  /// Whether an unenroll, including its reauthentication, is in flight, or the ``AuthService``
  /// is signing in.
  public let isLoading: Bool

  /// The localized message of the last failed unenroll. It clears when the next attempt starts.
  /// The sheet's error alert still shows for the same failure.
  public let errorMessage: String?

  /// Creates a state, for example to preview custom content with stub actions.
  public init(unenroll: @escaping @MainActor (_ factorUid: String) -> Void,
              goToEnrollment: @escaping @MainActor () -> Void,
              refresh: @escaping @MainActor () -> Void,
              enrolledFactors: [MultiFactorInfo],
              isLoading: Bool,
              errorMessage: String?) {
    self.unenroll = unenroll
    self.goToEnrollment = goToEnrollment
    self.refresh = refresh
    self.enrolledFactors = enrolledFactors
    self.isLoading = isLoading
    self.errorMessage = errorMessage
  }
}

/// The MFA management screen, with its content drawn by you.
///
/// The screen loads the enrolled factors, unenrolls them, presents reauthentication when
/// Firebase requires it, navigates, and reports errors. Your content only draws the UI from the
/// ``MFAManagementContentState`` it receives. Wrap ``DefaultMFAManagementContent`` to keep the
/// stock markup.
///
/// Example:
/// ```swift
/// AuthPickerView { authenticatedApp }
///   .pickerDestination { screen in
///     switch screen {
///     case .mfaManagement:
///       MFAManagementScreen { state in
///         ForEach(state.enrolledFactors) { factor in
///           Button("Remove \(factor.displayName ?? factor.uid)") {
///             state.unenroll(factor.uid)
///           }
///           .disabled(state.isLoading)
///         }
///         Button("Add method", action: state.goToEnrollment)
///       }
///     default:
///       DefaultAuthPickerDestination(screen: screen)
///     }
///   }
/// ```
@MainActor
public struct MFAManagementScreen<Content: View>: View {
  public init(@ViewBuilder content: @escaping (MFAManagementContentState) -> Content) {
    self.content = content
  }

  @Environment(AuthService.self) private var authService
  @Environment(\.reportError) private var reportError
  @State private var enrolledFactors: [MultiFactorInfo] = []
  @State private var isWorking = false
  @State private var errorMessage: String?
  @State private var reauthCoordinator = ReauthenticationCoordinator()

  private let content: (MFAManagementContentState) -> Content

  public var body: some View {
    content(MFAManagementContentState(
      unenroll: unenroll,
      goToEnrollment: { authService.navigator.push(.mfaEnrollment) },
      refresh: refresh,
      enrolledFactors: enrolledFactors,
      isLoading: isLoading,
      errorMessage: errorMessage
    ))
    .withReauthentication(coordinator: reauthCoordinator)
    .onAppear(perform: refresh)
  }

  private var isLoading: Bool {
    isWorking || authService.authenticationState == .authenticating
  }

  private func refresh() {
    guard let user = authService.currentUser else { return }
    enrolledFactors = user.multiFactor.enrolledFactors
  }

  private func unenroll(_ factorUid: String) {
    guard !isLoading else { return }
    isWorking = true
    errorMessage = nil
    Task {
      defer { isWorking = false }
      do {
        try await withReauthenticationIfNeeded(
          authService: authService,
          coordinator: reauthCoordinator
        ) {
          enrolledFactors = try await authService.unenrollMFA(factorUid)
        }
      } catch {
        errorMessage = authService.string.localizedErrorMessage(for: error)
        reportError?(error)
      }
    }
  }
}
