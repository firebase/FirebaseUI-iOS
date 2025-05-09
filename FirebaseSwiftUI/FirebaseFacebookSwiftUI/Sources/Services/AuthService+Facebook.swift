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
    facebookProvider = FacebookProviderAuthUI(scopes: scopes)
    register(provider: facebookProvider!)
    return self
  }
}
