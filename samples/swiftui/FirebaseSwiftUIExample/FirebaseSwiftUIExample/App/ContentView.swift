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

import AppTrackingTransparency
import FirebaseAppleSwiftUI
import FirebaseAuth
import FirebaseAuthSwiftUI
import FirebaseFacebookSwiftUI
import FirebaseGoogleSwiftUI
import FirebaseOAuthSwiftUI
import FirebasePhoneAuthSwiftUI
import FirebaseTwitterSwiftUI
import SwiftUI

struct ContentView: View {
  init() {
    Auth.auth().signInAnonymously()
    let actionCodeSettings = ActionCodeSettings()
    actionCodeSettings.handleCodeInApp = true
    actionCodeSettings
      .url = URL(string: "https://flutterfire-e2e-tests.firebaseapp.com")
    actionCodeSettings.linkDomain = "flutterfire-e2e-tests.firebaseapp.com"
    actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
    let configuration = AuthConfiguration(
      shouldAutoUpgradeAnonymousUsers: true,
      tosUrl: URL(string: "https://example.com/tos"),
      privacyPolicyUrl: URL(string: "https://example.com/privacy"),
      emailLinkSignInActionCodeSettings: actionCodeSettings,
      mfaEnabled: true
    )

    authService = AuthService(
      configuration: configuration
    )
    .withAppleSignIn()
    .withPhoneSignIn()
    .withGoogleSignIn()
    .withFacebookSignIn(FacebookProviderSwift())
    .withTwitterSignIn()
    .withOAuthSignIn(OAuthProviderSwift.github())
    .withOAuthSignIn(OAuthProviderSwift.microsoft())
    .withOAuthSignIn(OAuthProviderSwift.yahoo())
    .withOAuthSignIn(
      OAuthProviderSwift(
        providerId: "oidc.line",
        displayName: "Sign in with LINE",
        buttonIcon: Image(.icLineLogo),
        buttonBackgroundColor: .lineButton,
        buttonForegroundColor: .white
      )
    )
    .withEmailSignIn()
  }

  let authService: AuthService

  var body: some View {
    AuthPickerView {
      usersApp
    }
    .environment(authService)
  }

  var usersApp: some View {
    NavigationStack {
      VStack {
        if authService.authenticationState == .unauthenticated {
          Text("Not Authenticated")
          Button {
            authService.isPresented = true
          } label: {
            Text("Authenticate")
          }
          .buttonStyle(.bordered)
        } else {
          Text("Authenticated - \(authService.currentUser?.email ?? "")")
          Button {
            authService.isPresented = true // Reopen the sheet
          } label: {
            Text("Manage Account")
          }
          .buttonStyle(.bordered)
          Button {
            Task {
              try? await authService.signOut()
            }
          } label: {
            Text("Sign Out")
          }
          .buttonStyle(.borderedProminent)
        }
      }
      .navigationTitle("Firebase UI Demo")
    }
    .onAppear {
      authService.isPresented = authService.authenticationState == .unauthenticated
    }
    .onChange(of: authService.authenticationState) { _, newValue in
      debugPrint("authService.authenticationState - \(newValue)")
      if newValue != .authenticating {
        authService.isPresented = newValue == .unauthenticated
      }
    }
  }
}
