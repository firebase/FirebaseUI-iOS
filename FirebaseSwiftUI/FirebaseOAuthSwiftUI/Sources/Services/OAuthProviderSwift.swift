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

import FirebaseAuth
import FirebaseAuthSwiftUI
import FirebaseCore
import SwiftUI

/// Configuration for a generic OAuth provider
public class OAuthProviderSwift: CredentialAuthProviderSwift {
  public let providerId: String
  public let scopes: [String]
  public let customParameters: [String: String]
  // Button appearance
  public let buttonLabel: String
  public let displayName: String
  public let buttonIcon: Image
  public let buttonBackgroundColor: Color
  public let buttonForegroundColor: Color
  /// Initialize a generic OAuth provider
  /// - Parameters:
  ///   - providerId: The OAuth provider ID (e.g., "github.com", "microsoft.com")
  ///   - scopes: OAuth scopes to request
  ///   - customParameters: Additional OAuth parameters
  ///   - buttonLabel: Full button label (e.g., "Sign in with GitHub")
  ///   - displayName: Short provider name for messages (e.g., "GitHub")
  ///   - buttonIcon: Button icon image
  ///   - buttonBackgroundColor: Button background color
  ///   - buttonForegroundColor: Button text/icon color
  public init(providerId: String,
              scopes: [String] = [],
              customParameters: [String: String] = [:],
              buttonLabel: String,
              displayName: String,
              buttonIcon: Image,
              buttonBackgroundColor: Color = .black,
              buttonForegroundColor: Color = .white) {
    self.providerId = providerId
    self.scopes = scopes
    self.customParameters = customParameters
    self.buttonLabel = buttonLabel
    self.displayName = displayName
    self.buttonIcon = buttonIcon
    self.buttonBackgroundColor = buttonBackgroundColor
    self.buttonForegroundColor = buttonForegroundColor
  }

  /// Convenience initializer using SF Symbol
  /// - Parameters:
  ///   - providerId: The OAuth provider ID (e.g., "github.com", "microsoft.com")
  ///   - scopes: OAuth scopes to request
  ///   - customParameters: Additional OAuth parameters
  ///   - buttonLabel: Full button label (e.g., "Sign in with GitHub")
  ///   - displayName: Short provider name for messages (e.g., "GitHub")
  ///   - iconSystemName: SF Symbol name
  ///   - buttonBackgroundColor: Button background color
  ///   - buttonForegroundColor: Button text/icon color
  public convenience init(providerId: String,
                          scopes: [String] = [],
                          customParameters: [String: String] = [:],
                          buttonLabel: String,
                          displayName: String,
                          iconSystemName: String,
                          buttonBackgroundColor: Color = .black,
                          buttonForegroundColor: Color = .white) {
    self.init(
      providerId: providerId,
      scopes: scopes,
      customParameters: customParameters,
      buttonLabel: buttonLabel,
      displayName: displayName,
      buttonIcon: Image(systemName: iconSystemName),
      buttonBackgroundColor: buttonBackgroundColor,
      buttonForegroundColor: buttonForegroundColor
    )
  }

  @MainActor public func createAuthCredential() async throws -> AuthCredential {
    let provider = OAuthProvider(providerID: providerId)

    // Set scopes if provided
    if !scopes.isEmpty {
      provider.scopes = scopes
    }
    // Set custom parameters if provided
    if !customParameters.isEmpty {
      provider.customParameters = customParameters
    }

    return try await withCheckedThrowingContinuation { continuation in
      provider.getCredentialWith(nil) { credential, error in
        if let error = error {
          continuation.resume(
            throwing: AuthServiceError.signInFailed(underlying: error)
          )
          return
        }

        guard let credential = credential else {
          continuation.resume(
            throwing: AuthServiceError.invalidCredentials(
              "\(self.providerId) did not provide a valid AuthCredential"
            )
          )
          return
        }

        continuation.resume(returning: credential)
      }
    }
  }
}

public class OAuthProviderAuthUI: AuthProviderUI {
  private let typedProvider: OAuthProviderSwift
  public var provider: AuthProviderSwift { typedProvider }

  public init(provider: OAuthProviderSwift) {
    typedProvider = provider
  }

  public var id: String {
    return typedProvider.providerId
  }

  public var displayName: String {
    return typedProvider.displayName
  }

  @MainActor public func authButton() -> AnyView {
    AnyView(GenericOAuthButton(provider: typedProvider))
  }
}
