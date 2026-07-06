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

/// Styling configuration for the primary call-to-action buttons used throughout the auth flow
/// (sign in, send code, update password, etc). Color already follows the environment's `.tint()`
/// via `.buttonStyle(.borderedProminent)`; this covers what `.tint()` doesn't — shape and font.
/// Both fields default to `nil`, in which case today's exact appearance is unchanged.
public struct AuthCTAButtonStyle: Sendable {
  public var shape: ButtonBorderShape?
  public var font: Font?

  public init(shape: ButtonBorderShape? = nil, font: Font? = nil) {
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

/// Applies `.buttonStyle(.borderedProminent)` plus the shape/font from the environment's
/// ``AuthCTAButtonStyle``, in place of a bare `.buttonStyle(.borderedProminent)` call.
struct AuthCTAButtonModifier: ViewModifier {
  @Environment(\.authCTAButtonStyle) private var style

  func body(content: Content) -> some View {
    if let font = style.font {
      content
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(style.shape ?? .automatic)
        .font(font)
    } else {
      content
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(style.shape ?? .automatic)
    }
  }
}

public extension View {
  /// Applies the auth flow's primary call-to-action button styling, reading shape/font from
  /// the environment's ``AuthCTAButtonStyle`` (set via `.authCTAButtonStyle(_:)`).
  func authCTAButtonStyle() -> some View {
    modifier(AuthCTAButtonModifier())
  }

  /// Sets the ``AuthCTAButtonStyle`` used by every CTA button in this view's subtree.
  ///
  /// ```swift
  /// AuthPickerView { ... }
  ///   .authCTAButtonStyle(AuthCTAButtonStyle(shape: .capsule))
  /// ```
  func authCTAButtonStyle(_ style: AuthCTAButtonStyle) -> some View {
    environment(\.authCTAButtonStyle, style)
  }
}
