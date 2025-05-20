//
//  AuthService+Phone.swift
//  FirebaseUI
//
//  Created by Russell Wheatley on 09/05/2025.
//

import FirebaseAuthSwiftUI

public extension AuthService {
  @discardableResult
  func withPhoneSignIn() -> AuthService {
    register(provider: PhoneAuthProviderAuthUI())
    return self
  }
}
