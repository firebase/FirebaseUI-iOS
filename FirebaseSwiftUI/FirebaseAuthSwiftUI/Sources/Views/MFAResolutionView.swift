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

import FirebaseCore
import SwiftUI

@MainActor
public struct MFAResolutionView {
  let mfaRequired: MFARequired

  public init(mfaRequired: MFARequired) {
    self.mfaRequired = mfaRequired
  }
}

extension MFAResolutionView: View {
  public var body: some View {
    MFAResolutionScreen(mfaRequired: mfaRequired) { DefaultMFAResolutionContent(state: $0) }
  }
}

#Preview("Phone SMS Only") {
  FirebaseOptions.dummyConfigurationForPreview()
  let authService = AuthService()
  let mfaRequired = MFARequired(hints: [
    .phone(displayName: "Work Phone", uid: "phone-uid-1", phoneNumber: "+15551234567"),
  ])
  return MFAResolutionView(mfaRequired: mfaRequired).environment(authService)
}

#Preview("TOTP Only") {
  FirebaseOptions.dummyConfigurationForPreview()
  let authService = AuthService()
  let mfaRequired = MFARequired(hints: [
    .totp(displayName: "Authenticator App", uid: "totp-uid-1"),
  ])
  return MFAResolutionView(mfaRequired: mfaRequired).environment(authService)
}

#Preview("Multiple Methods") {
  FirebaseOptions.dummyConfigurationForPreview()
  let authService = AuthService()
  let mfaRequired = MFARequired(hints: [
    .phone(displayName: "Mobile", uid: "phone-uid-1", phoneNumber: "+15551234567"),
    .totp(displayName: "Google Authenticator", uid: "totp-uid-1"),
  ])
  return MFAResolutionView(mfaRequired: mfaRequired).environment(authService)
}

#Preview("Single TOTP") {
  FirebaseOptions.dummyConfigurationForPreview()
  let authService = AuthService()
  let mfaRequired = MFARequired(hints: [
    .totp(displayName: "Authenticator", uid: "totp-uid-1"),
  ])
  return MFAResolutionView(mfaRequired: mfaRequired).environment(authService)
}
