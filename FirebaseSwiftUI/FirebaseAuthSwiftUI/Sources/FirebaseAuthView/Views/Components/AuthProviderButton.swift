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

struct AuthProviderButton: View {
  let provider: AuthProvider
  let onClick: (AuthProvider) -> Void
  var enabled: Bool = true
  var style: ProviderStyle? = nil
  
  private var resolvedStyle: ProviderStyle {
    style ?? provider.providerStyle
  }
  
  var body: some View {
    let providerStyle = resolvedStyle
    Button {
      onClick(provider)
    } label: {
      HStack(spacing: 12) {
        if let iconResource = providerStyle.icon {
          providerIcon(for: iconResource, tint: providerStyle.iconTint)
        }
        Text(provider.buttonTitle)
          .lineLimit(1)
          .truncationMode(.tail)
          .foregroundStyle(providerStyle.contentColor)
      }
    }
    .buttonStyle(ProviderButtonStyle(style: providerStyle))
    .disabled(!enabled)
  }
  
  @ViewBuilder
  private func providerIcon(for resource: ImageResource, tint: Color?) -> some View {
    if let tint {
      Image(resource)
        .renderingMode(.template)
        .resizable()
        .scaledToFit()
        .frame(width: 24, height: 24)
        .foregroundStyle(tint)
    } else {
      Image(resource)
        .renderingMode(.original)
        .resizable()
        .scaledToFit()
        .frame(width: 24, height: 24)
    }
  }
}

private struct ProviderButtonStyle: PrimitiveButtonStyle {
  let style: ProviderStyle
  
  func makeBody(configuration: Configuration) -> some View {
    Button(action: configuration.trigger) {
      configuration.label
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
  }
}
