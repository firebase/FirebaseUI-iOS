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
import FirebaseTwitterSwiftUI
import FirebaseAppleSwiftUI
import FirebaseOAuthSwiftUI
import SwiftUI

struct ContentView: View {
  let authService: AuthService

  init() {
    let actionCodeSettings = ActionCodeSettings()
    actionCodeSettings.handleCodeInApp = true
    actionCodeSettings
      .url = URL(string: "https://flutterfire-e2e-tests.firebaseapp.com")
    actionCodeSettings.linkDomain = "flutterfire-e2e-tests.firebaseapp.com"
    actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
    let configuration = AuthConfiguration(
      tosUrl: URL(string: "https://example.com/tos"),
      privacyPolicyUrl: URL(string: "https://example.com/privacy"),
      emailLinkSignInActionCodeSettings: actionCodeSettings,
      mfaEnabled: true
    )

    authService = AuthService(
      configuration: configuration
    )
    .withGoogleSignIn()
    .withPhoneSignIn()
    .withAppleSignIn()
    .withTwitterSignIn()
    .withOAuthSignIn(OAuthProviderSwift.github())
    .withOAuthSignIn(OAuthProviderSwift.microsoft())
    .withOAuthSignIn(OAuthProviderSwift.yahoo())
    .withFacebookSignIn()
    .withEmailSignIn()

  }

  var body: some View {
    NavigationStack {
      AuthPickerView().environment(authService)
    }
  }
}
