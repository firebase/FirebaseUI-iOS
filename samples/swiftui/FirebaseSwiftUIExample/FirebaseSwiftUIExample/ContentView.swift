//
//  ContentView.swift
//  FirebaseSwiftUIExample
//
//  Created by Russell Wheatley on 23/04/2025.
//

import FirebaseAuth
import FirebaseAuthSwiftUI
import FirebaseFacebookSwiftUI
import FirebaseGoogleSwiftUI
import FirebasePhoneAuthSwiftUI
import SwiftUI

struct ContentView: View {
  let authService: AuthService

  init() {
    // Auth.auth().signInAnonymously()

    let actionCodeSettings = ActionCodeSettings()
    actionCodeSettings.handleCodeInApp = true
    actionCodeSettings
      .url = URL(string: "https://flutterfire-e2e-tests.firebaseapp.com")
    actionCodeSettings.linkDomain = "flutterfire-e2e-tests.firebaseapp.com"
    actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
    let configuration = AuthConfiguration(
      shouldAutoUpgradeAnonymousUsers: true,
      emailLinkSignInActionCodeSettings: actionCodeSettings
    )
    let facebookProvider = FacebookProviderSwift()
    let phoneAuthProvider = PhoneAuthProviderSwift()
    authService = AuthService(
      configuration: configuration,
      googleProvider: googleProvider,
      facebookProvider: facebookProvider,
      phoneAuthProvider: phoneAuthProvider
    )
  }

  var body: some View {
    AuthPickerView {
      SignInWithGoogleButton()
      SignInWithFacebookButton()
      PhoneAuthButtonView()
    }.environment(authService)
  }
}
