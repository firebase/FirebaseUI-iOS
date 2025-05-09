//
//  AuthService+Google.swift
//  FirebaseUI
//
//  Created by Morgan Chen on 4/16/25.
//

import FirebaseAuthSwiftUI

public extension AuthService {
  @discardableResult
  func withGoogleSignIn(scopes scopes: [String]? = nil) -> AuthService {
    let clientID = auth.app?.options.clientID ?? ""
    googleProvider = GoogleProviderAuthUI(scopes: scopes, clientID: clientID)
    register(provider: googleProvider!)
    return self
  }
}
