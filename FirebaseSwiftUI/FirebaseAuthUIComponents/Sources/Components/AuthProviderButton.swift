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

/// A styled button component for authentication providers
/// Used by all provider packages to maintain consistent UI
public struct AuthProviderButton: View {
  let label: String
  let style: ProviderStyle
  let action: () -> Void
  var enabled: Bool
  var accessibilityId: String?

  public init(label: String,
              style: ProviderStyle,
              enabled: Bool = true,
              accessibilityId: String? = nil,
              action: @escaping () -> Void) {
    self.label = label
    self.style = style
    self.enabled = enabled
    self.accessibilityId = accessibilityId
    self.action = action
  }

  public var body: some View {
    Button(action: action) {
      HStack(spacing: 12) {
        if let icon = style.icon {
          providerIcon(for: icon, tint: style.iconTint)
        }
        Text(label)
          .lineLimit(1)
          .truncationMode(.tail)
          .foregroundStyle(style.contentColor)
      }
      .padding(.horizontal, 8)
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .buttonStyle(.borderedProminent)
    .tint(style.backgroundColor)
    .shadow(
      color: Color.black.opacity(0.12),
      radius: Double(style.elevation),
      x: 0,
      y: style.elevation > 0 ? 1 : 0
    )
    .disabled(!enabled)
    .accessibilityIdentifier(accessibilityId ?? "auth-provider-button")
  }

  @ViewBuilder
  private func providerIcon(for image: Image, tint: Color?) -> some View {
    if let tint {
      image
        .renderingMode(.template)
        .resizable()
        .scaledToFit()
        .frame(width: 24, height: 24)
        .foregroundStyle(tint)
    } else {
      image
        .renderingMode(.original)
        .resizable()
        .scaledToFit()
        .frame(width: 24, height: 24)
    }
  }
}
