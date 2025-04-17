//
//  AuthService+Google.swift
//  FirebaseUI
//
//  Created by Morgan Chen on 4/16/25.
//

import FirebaseAuthSwiftUI

extension AuthService {

  @discardableResult
  func withGoogleSignIn() -> AuthService {
    let clientID = auth.app?.options.clientID ?? ""
    self.googleProvider = GoogleProviderSwift(clientID: clientID)
    return self
  }

}
