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
public struct MFAEnrolmentView {
  public init() {}
}

extension MFAEnrolmentView: View {
  public var body: some View {
    MFAEnrolmentScreen { DefaultMFAEnrolmentContent(state: $0) }
  }
}

#Preview("MFA Enabled - Both Methods") {
  FirebaseOptions.dummyConfigurationForPreview()
  let config = AuthConfiguration(
    mfaEnabled: true,
    allowedSecondFactors: [.sms, .totp]
  )
  let authService = AuthService(configuration: config)
  return MFAEnrolmentView()
    .environment(authService)
}

#Preview("MFA Disabled") {
  FirebaseOptions.dummyConfigurationForPreview()
  let config = AuthConfiguration(
    mfaEnabled: false,
    allowedSecondFactors: []
  )
  let authService = AuthService(configuration: config)
  return MFAEnrolmentView()
    .environment(authService)
}

#Preview("No Allowed Factors") {
  FirebaseOptions.dummyConfigurationForPreview()
  let config = AuthConfiguration(
    mfaEnabled: true,
    allowedSecondFactors: []
  )
  let authService = AuthService(configuration: config)
  return MFAEnrolmentView()
    .environment(authService)
}

#Preview("SMS Only") {
  FirebaseOptions.dummyConfigurationForPreview()
  let config = AuthConfiguration(
    mfaEnabled: true,
    allowedSecondFactors: [.sms]
  )
  let authService = AuthService(configuration: config)
  return MFAEnrolmentView()
    .environment(authService)
}

#Preview("TOTP Only") {
  FirebaseOptions.dummyConfigurationForPreview()
  let config = AuthConfiguration(
    mfaEnabled: true,
    allowedSecondFactors: [.totp]
  )
  let authService = AuthService(configuration: config)
  return MFAEnrolmentView()
    .environment(authService)
}
