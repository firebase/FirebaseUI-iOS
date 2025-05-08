//
//  AuthService+Google.swift
//  FirebaseUI
//
//  Created by Morgan Chen on 4/16/25.
//

import FirebaseAuthSwiftUI

public extension AuthService {
  @discardableResult
  func withGoogleSignIn() -> AuthService {
    let clientID = auth.app?.options.clientID ?? ""
    googleProvider = GoogleProviderAuthUI(clientID: clientID)
    return self
  }
}
