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
      displayName: "Sign in with GitHub",
      iconSystemName: "chevron.left.forwardslash.chevron.right",
      buttonBackgroundColor: .black,
      buttonForegroundColor: .white
    )
  }
  
  /// Microsoft OAuth provider
  /// - Parameters:
  ///   - scopes: Microsoft scopes (default: ["openid", "profile", "email"])
  ///   - Returns: Configured Microsoft provider
  static func microsoft(scopes: [String] = ["openid", "profile", "email"]) -> OAuthProviderSwift {
    return OAuthProviderSwift(
      providerId: "microsoft.com",
      scopes: scopes,
      customParameters:  ["prompt" : "consent"],
      displayName: "Sign in with Microsoft",
      iconSystemName: "building.2",
      buttonBackgroundColor: Color(red: 0/255, green: 120/255, blue: 212/255),
      buttonForegroundColor: .white
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
      customParameters:  ["prompt" : "consent"],
      displayName: "Sign in with Yahoo",
      iconSystemName: "y.circle.fill",
      buttonBackgroundColor: Color(red: 80/255, green: 0/255, blue: 155/255),
      buttonForegroundColor: .white
    )
  }
  
  /// LinkedIn OAuth provider
  /// - Parameters:
  ///   - scopes: LinkedIn scopes (default: ["r_liteprofile", "r_emailaddress"])
  ///   - Returns: Configured LinkedIn provider
  static func linkedIn(scopes: [String] = ["r_liteprofile", "r_emailaddress"]) -> OAuthProviderSwift {
    return OAuthProviderSwift(
      providerId: "linkedin.com",
      scopes: scopes,
      displayName: "Sign in with LinkedIn",
      iconSystemName: "link",
      buttonBackgroundColor: Color(red: 0/255, green: 119/255, blue: 181/255),
      buttonForegroundColor: .white
    )
  }
}

