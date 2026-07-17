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

/// Typography configuration for the auth flow. `fontFamily` defaults to `nil`, in which case
/// text keeps using the system font at each semantic text style, exactly as it does today.
public struct AuthTypography: Sendable {
  /// The PostScript name of a custom font registered with the app (e.g. via Info.plist).
  public var fontFamily: String?

  public init(fontFamily: String? = nil) {
    self.fontFamily = fontFamily
  }

  public static let `default` = AuthTypography()

  /// Resolves a semantic text style against this typography's `fontFamily`, preserving Dynamic
  /// Type scaling relative to `style`. Falls back to the system font when `fontFamily` is unset.
  public func resolvedFont(for style: Font.TextStyle, weight: Font.Weight? = nil) -> Font {
    let base: Font = if let fontFamily {
      .custom(fontFamily, size: UIFont.preferredFont(forTextStyle: style.uiKit).pointSize, relativeTo: style)
    } else {
      .system(style)
    }
    return weight.map { base.weight($0) } ?? base
  }
}

private struct AuthTypographyKey: EnvironmentKey {
  static let defaultValue: AuthTypography = .default
}

public extension EnvironmentValues {
  var authTypography: AuthTypography {
    get { self[AuthTypographyKey.self] }
    set { self[AuthTypographyKey.self] = newValue }
  }
}

public extension View {
  /// Sets the custom font family used by every semantic text style (`.headline`, `.body`,
  /// `.caption`, etc.) throughout the auth flow, while preserving Dynamic Type scaling relative
  /// to each style.
  ///
  /// ```swift
  /// AuthPickerView { ... }
  ///   .authTypography(AuthTypography(fontFamily: "Poppins-Regular"))
  /// ```
  func authTypography(_ typography: AuthTypography) -> some View {
    environment(\.authTypography, typography)
  }
}

public struct AuthFontModifier: ViewModifier {
  @Environment(\.authTypography) private var typography
  let style: Font.TextStyle
  var weight: Font.Weight?

  public func body(content: Content) -> some View {
    content.font(typography.resolvedFont(for: style, weight: weight))
  }
}

public extension View {
  /// Applies a semantic text style, resolved against the environment's ``AuthTypography`` —
  /// use in place of a bare `.font(.headline)`/`.font(.caption)`/etc. call.
  func authFont(_ style: Font.TextStyle, weight: Font.Weight? = nil) -> some View {
    modifier(AuthFontModifier(style: style, weight: weight))
  }
}

private extension Font.TextStyle {
  var uiKit: UIFont.TextStyle {
    switch self {
    case .largeTitle: .largeTitle
    case .title: .title1
    case .title2: .title2
    case .title3: .title3
    case .headline: .headline
    case .subheadline: .subheadline
    case .body: .body
    case .callout: .callout
    case .footnote: .footnote
    case .caption: .caption1
    case .caption2: .caption2
    @unknown default: .body
    }
  }
}
