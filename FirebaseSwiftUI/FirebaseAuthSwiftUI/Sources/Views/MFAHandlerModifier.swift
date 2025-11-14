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

/// Environment key for accessing the MFA handler
public struct MFAHandlerKey: @preconcurrency EnvironmentKey {
  @MainActor public static let defaultValue: ((MFARequired) -> Void)? = nil
}

public extension EnvironmentValues {
  var mfaHandler: ((MFARequired) -> Void)? {
    get { self[MFAHandlerKey.self] }
    set { self[MFAHandlerKey.self] = newValue }
  }
}

/// View modifier that handles MFA requirements at the view layer
/// Automatically navigates to MFA resolution when MFA is required
@MainActor
struct MFAHandlerModifier: ViewModifier {
  @Environment(AuthService.self) private var authService

  func body(content: Content) -> some View {
    content
      .environment(\.mfaHandler, handleMFARequired)
  }

  /// Handle MFA required - navigate to MFA resolution view
  func handleMFARequired(_ mfaRequired: MFARequired) {
    authService.navigator.push(.mfaResolution(mfaRequired))
  }
}

extension View {
  /// Adds MFA handling to the view hierarchy
  /// Should be applied at the NavigationStack level to handle MFA requirements throughout the auth
  /// flow
  func mfaHandler() -> some View {
    modifier(MFAHandlerModifier())
  }
}
