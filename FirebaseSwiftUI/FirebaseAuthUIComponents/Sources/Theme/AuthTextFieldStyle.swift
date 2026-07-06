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

/// Styling configuration for ``AuthTextField``. All fields default to `nil`, in which case
/// `AuthTextField` falls back to its existing hardcoded appearance.
public struct AuthTextFieldStyle: Sendable {
  public var tint: Color?
  public var containerColor: Color?
  public var secondaryColor: Color?
  public var errorColor: Color?
  public var cornerRadius: CGFloat?

  public init(tint: Color? = nil,
              containerColor: Color? = nil,
              secondaryColor: Color? = nil,
              errorColor: Color? = nil,
              cornerRadius: CGFloat? = nil) {
    self.tint = tint
    self.containerColor = containerColor
    self.secondaryColor = secondaryColor
    self.errorColor = errorColor
    self.cornerRadius = cornerRadius
  }

  public static let `default` = AuthTextFieldStyle()
}

private struct AuthTextFieldStyleKey: EnvironmentKey {
  static let defaultValue: AuthTextFieldStyle = .default
}

public extension EnvironmentValues {
  var authTextFieldStyle: AuthTextFieldStyle {
    get { self[AuthTextFieldStyleKey.self] }
    set { self[AuthTextFieldStyleKey.self] = newValue }
  }
}

public extension View {
  /// Applies a custom appearance to every ``AuthTextField`` in this view's subtree.
  ///
  /// ```swift
  /// AuthPickerView { ... }
  ///   .authTextFieldStyle(
  ///     AuthTextFieldStyle(
  ///       tint: theme.colors.tint,
  ///       containerColor: theme.colors.container,
  ///       secondaryColor: theme.colors.secondary,
  ///       errorColor: theme.colors.error
  ///     )
  ///   )
  /// ```
  func authTextFieldStyle(_ style: AuthTextFieldStyle) -> some View {
    environment(\.authTextFieldStyle, style)
  }
}
