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
public struct PhoneReauthView {
  let phoneNumber: String
  let coordinator: ReauthenticationCoordinator
}

extension PhoneReauthView: View {
  public var body: some View {
    PhoneReauthScreen(phoneNumber: phoneNumber, coordinator: coordinator) {
      DefaultPhoneReauthContent(state: $0)
    }
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  return PhoneReauthView(
    phoneNumber: "+1234567890",
    coordinator: ReauthenticationCoordinator()
  )
  .environment(AuthService())
}
