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

import SwiftUI

struct AuthMethodPickerListView: View {
  var onProviderSelected: (AuthProvider) -> Void
  
  var body: some View {
    GeometryReader { proxy in
      ScrollView {
        VStack(spacing: 16) {
          AuthProviderButton(
            provider: .apple,
            onClick: onProviderSelected
          )
          AuthProviderButton(
            provider: .anonymous,
            onClick: onProviderSelected
          )
          AuthProviderButton(
            provider: .email,
            onClick: onProviderSelected
          )
          AuthProviderButton(
            provider: .phone,
            onClick: onProviderSelected
          )
          AuthProviderButton(
            provider: .google,
            onClick: onProviderSelected
          )
          AuthProviderButton(
            provider: .facebook,
            onClick: onProviderSelected
          )
          AuthProviderButton(
            provider: .twitter,
            onClick: onProviderSelected
          )
          AuthProviderButton(
            provider: .github,
            onClick: onProviderSelected
          )
          AuthProviderButton(
            provider: .microsoft,
            onClick: onProviderSelected
          )
          AuthProviderButton(
            provider: .yahoo,
            onClick: onProviderSelected
          )
        }
        .padding(.horizontal, proxy.size.width * 0.18)
      }
    }
  }
}

#Preview {
  AuthMethodPickerListView { selectedProvider in }
}
