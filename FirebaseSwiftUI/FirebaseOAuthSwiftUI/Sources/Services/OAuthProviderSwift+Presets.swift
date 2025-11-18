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

/// Preset configurations for common OAuth providers
public extension OAuthProviderSwift {
  /// GitHub OAuth provider
  /// - Parameters:
  ///   - scopes: GitHub scopes (default: ["user"])
  ///   - Returns: Configured GitHub provider
  static func github(scopes: [String] = ["user"]) -> OAuthProviderSwift {
    return OAuthProviderSwift(
      providerId: "github.com",
      scopes: scopes,
      buttonLabel: "Sign in with GitHub",
      displayName: "GitHub",
      buttonIcon: ProviderStyle.github.icon!,
      buttonBackgroundColor: ProviderStyle.github.backgroundColor,
      buttonForegroundColor: ProviderStyle.github.contentColor
    )
  }

  /// Microsoft OAuth provider
  /// - Parameters:
  ///   - scopes: Microsoft scopes (default: ["user.readwrite"])
  ///   - Returns: Configured Microsoft provider
  static func microsoft(scopes: [String] = ["user.readwrite"]) -> OAuthProviderSwift {
    return OAuthProviderSwift(
      providerId: "microsoft.com",
      scopes: scopes,
      customParameters: ["prompt": "consent"],
      buttonLabel: "Sign in with Microsoft",
      displayName: "Microsoft",
      buttonIcon: ProviderStyle.microsoft.icon!,
      buttonBackgroundColor: ProviderStyle.microsoft.backgroundColor,
      buttonForegroundColor: ProviderStyle.microsoft.contentColor
    )
  }

  /// Yahoo OAuth provider
  /// - Parameters:
  ///   - scopes: Yahoo scopes (default: ["user.readwrite"])
  ///   - Returns: Configured Yahoo provider
  static func yahoo(scopes: [String] = ["user.readwrite"]) -> OAuthProviderSwift {
    return OAuthProviderSwift(
      providerId: "yahoo.com",
      scopes: scopes,
      customParameters: ["prompt": "consent"],
      buttonLabel: "Sign in with Yahoo",
      displayName: "Yahoo",
      buttonIcon: ProviderStyle.yahoo.icon!,
      buttonBackgroundColor: ProviderStyle.yahoo.backgroundColor,
      buttonForegroundColor: ProviderStyle.yahoo.contentColor
    )
  }
}
