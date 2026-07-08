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

import FirebaseAuthSwiftUI
import FirebaseAuthUIComponents
import SwiftUI

/// A custom sign-in-method layout — a horizontally scrollable row of icon buttons —
/// demonstrating `AuthPickerContentView.init(authMethodPicker:)` in place of the default
/// stacked button list.
struct SpotlightMethodPicker: View {
  let providers: [AuthProviderUI]
  let onProviderSelected: (AuthProviderUI) -> Void

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 20) {
        ForEach(providers, id: \.id) { provider in
          let style = styleForProvider(provider)
          Button {
            onProviderSelected(provider)
          } label: {
            VStack(spacing: 8) {
              Circle()
                .fill(style.backgroundColor)
                .frame(width: 56, height: 56)
                .overlay {
                  if let icon = style.icon {
                    icon
                      .resizable()
                      .scaledToFit()
                      .frame(width: 26, height: 26)
                      .foregroundStyle(style.contentColor)
                  } else {
                    Text(provider.displayName.prefix(1))
                      .foregroundStyle(style.contentColor)
                  }
                }
              Text(provider.displayName)
                .authFont(.body)
            }
          }
          .buttonStyle(.plain)
          .accessibilityIdentifier("spotlight-provider-\(provider.id)")
        }
      }
      .padding(.horizontal, 32)
    }
  }

  /// Maps each registered provider to its brand `ProviderStyle` — mirrors what
  /// `AuthService.renderButtons()` already does internally for the default layout, since a
  /// custom `authMethodPicker` builds its own buttons instead of reusing each provider's
  /// wrapper view.
  private func styleForProvider(_ provider: AuthProviderUI) -> ProviderStyle {
    switch provider.id {
    case "apple.com": .apple
    case "google.com": .google
    case "facebook.com": .facebook
    case "twitter.com": .twitter
    case "github.com": .github
    case "microsoft.com": .microsoft
    case "yahoo.com": .yahoo
    case "phone": .phone
    default: .empty
    }
  }
}
