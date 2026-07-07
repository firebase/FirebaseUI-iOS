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

import FirebaseAuthUIComponents
import SwiftUI

/// Styling configuration for the primary call-to-action buttons used throughout the auth flow
/// (sign in, send code, update password, etc). All fields default to `nil`, in which case
/// today's exact appearance is unchanged — including `backgroundColor`, which otherwise already
/// follows the environment's `.tint()` via `.buttonStyle(.borderedProminent)`; setting it here
/// overrides that for CTA buttons specifically, without affecting `.tint()` elsewhere.
public struct AuthCTAButtonStyle: Sendable {
  public var backgroundColor: Color?
  public var contentColor: Color?
  public var shape: ButtonBorderShape?
  public var font: Font?

  public init(backgroundColor: Color? = nil,
              contentColor: Color? = nil,
              shape: ButtonBorderShape? = nil,
              font: Font? = nil) {
    self.backgroundColor = backgroundColor
    self.contentColor = contentColor
    self.shape = shape
    self.font = font
  }

  public static let `default` = AuthCTAButtonStyle()
}

private struct AuthCTAButtonStyleKey: EnvironmentKey {
  static let defaultValue: AuthCTAButtonStyle = .default
}

public extension EnvironmentValues {
  var authCTAButtonStyle: AuthCTAButtonStyle {
    get { self[AuthCTAButtonStyleKey.self] }
    set { self[AuthCTAButtonStyleKey.self] = newValue }
  }
}

/// Applies `.buttonStyle(.borderedProminent)` plus the colors/shape/font from the environment's
/// ``AuthCTAButtonStyle``, in place of a bare `.buttonStyle(.borderedProminent)` call. When
/// `style.font` is left unset, the button falls back to ``AuthTypography`` (via `.authFont(_:)`)
/// so it stays consistent with the rest of the auth flow's typography by default — an explicit
/// `style.font` still overrides that, for buttons that should intentionally look different.
struct AuthCTAButtonModifier: ViewModifier {
  @Environment(\.authCTAButtonStyle) private var style

  func body(content: Content) -> some View {
    Group {
      if let contentColor = style.contentColor {
        content.foregroundStyle(contentColor)
      } else {
        content
      }
    }
    .buttonStyle(.borderedProminent)
    .buttonBorderShape(style.shape ?? .automatic)
    .tint(style.backgroundColor)
    .modifier(CTAFontModifier(explicitFont: style.font))
  }
}

private struct CTAFontModifier: ViewModifier {
  let explicitFont: Font?

  func body(content: Content) -> some View {
    if let explicitFont {
      content.font(explicitFont)
    } else {
      content.authFont(.headline)
    }
  }
}

public extension View {
  /// Applies the auth flow's primary call-to-action button styling, reading colors/shape/font
  /// from the environment's ``AuthCTAButtonStyle`` (set via `.authCTAButtonStyle(_:)`).
  func authCTAButtonStyle() -> some View {
    modifier(AuthCTAButtonModifier())
  }

  /// Sets the ``AuthCTAButtonStyle`` used by every CTA button in this view's subtree.
  ///
  /// ```swift
  /// AuthPickerView { ... }
  ///   .authCTAButtonStyle(
  ///     AuthCTAButtonStyle(backgroundColor: theme.colors.tint, contentColor: .white, shape: .capsule)
  ///   )
  /// ```
  func authCTAButtonStyle(_ style: AuthCTAButtonStyle) -> some View {
    environment(\.authCTAButtonStyle, style)
  }
}
