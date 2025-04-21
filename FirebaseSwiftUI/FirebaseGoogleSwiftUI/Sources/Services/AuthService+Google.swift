//
//  AuthService+Google.swift
//  FirebaseUI
//
//  Created by Morgan Chen on 4/16/25.
//

import FirebaseAuthSwiftUI

public extension AuthService {

  @discardableResult
  public func withGoogleSignIn() -> AuthService {
    let clientID = auth.app?.options.clientID ?? ""
    self.googleProvider = GoogleProviderSwift(clientID: clientID)
    return self
  }

}
