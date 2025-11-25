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

/// Styling configuration for authentication provider buttons
public struct ProviderStyle: Sendable {
  public init(icon: Image? = nil,
              backgroundColor: Color,
              contentColor: Color,
              iconTint: Color? = nil,
              elevation: CGFloat = 2) {
    self.icon = icon
    self.backgroundColor = backgroundColor
    self.contentColor = contentColor
    self.iconTint = iconTint
    self.elevation = elevation
  }

  public let icon: Image?
  public let backgroundColor: Color
  public let contentColor: Color
  public var iconTint: Color?
  public let shape: AnyShape = .init(RoundedRectangle(cornerRadius: 4, style: .continuous))
  public let elevation: CGFloat

  public static let empty = ProviderStyle(
    icon: nil,
    backgroundColor: .white,
    contentColor: .black
  )

  // MARK: - Predefined Styles

  public static var google: ProviderStyle {
    ProviderStyle(
      icon: Image(.fuiIcGoogleg),
      backgroundColor: Color(hex: 0xFFFFFF),
      contentColor: Color(hex: 0x757575)
    )
  }

  public static var facebook: ProviderStyle {
    ProviderStyle(
      icon: Image(.fuiIcFacebook),
      backgroundColor: Color(hex: 0x1877F2),
      contentColor: Color(hex: 0xFFFFFF)
    )
  }

  public static var twitter: ProviderStyle {
    ProviderStyle(
      icon: Image(.fuiIcTwitterX),
      backgroundColor: Color.black,
      contentColor: Color(hex: 0xFFFFFF)
    )
  }

  public static var apple: ProviderStyle {
    ProviderStyle(
      icon: Image(.fuiIcApple),
      backgroundColor: Color(hex: 0x000000),
      contentColor: Color(hex: 0xFFFFFF)
    )
  }

  public static var phone: ProviderStyle {
    ProviderStyle(
      icon: Image(.fuiIcPhone),
      backgroundColor: Color(hex: 0x43C5A5),
      contentColor: Color(hex: 0xFFFFFF)
    )
  }

  public static var github: ProviderStyle {
    ProviderStyle(
      icon: Image(.fuiIcGithub),
      backgroundColor: Color(hex: 0x24292E),
      contentColor: Color(hex: 0xFFFFFF)
    )
  }

  public static var microsoft: ProviderStyle {
    ProviderStyle(
      icon: Image(.fuiIcMicrosoft),
      backgroundColor: Color(hex: 0x2F2F2F),
      contentColor: Color(hex: 0xFFFFFF)
    )
  }

  public static var yahoo: ProviderStyle {
    ProviderStyle(
      icon: Image(.fuiIcYahoo),
      backgroundColor: Color(hex: 0x720E9E),
      contentColor: Color(hex: 0xFFFFFF)
    )
  }

  public static var anonymous: ProviderStyle {
    ProviderStyle(
      icon: Image(.fuiIcAnonymous),
      backgroundColor: Color(hex: 0xF4B400),
      contentColor: Color(hex: 0xFFFFFF)
    )
  }

  public static var email: ProviderStyle {
    ProviderStyle(
      icon: Image(.fuiIcMail),
      backgroundColor: Color(hex: 0xD0021B),
      contentColor: Color(hex: 0xFFFFFF)
    )
  }
}
