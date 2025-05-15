//
//  AuthService+Facebook.swift
//  FirebaseUI
//
//  Created by Russell Wheatley on 01/05/2025.
//

import FirebaseAuthSwiftUI

public extension AuthService {
  @discardableResult
  func withFacebookSignIn(scopes scopes: [String]? = nil) -> AuthService {
    FacebookProviderAuthUI.configureProvider(scopes: scopes)
    register(provider: FacebookProviderAuthUI.shared)
    return self
  }
}
