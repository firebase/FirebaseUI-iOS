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
  // State for Facebook Limited Login toggle
  @State private var useLimitedLogin = true
  let facebookProvider: FacebookProviderSwift

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

    // Create Facebook provider with Limited Login enabled by default
    let fbProvider = FacebookProviderSwift()
    fbProvider.setLimitedLogin(true)
    facebookProvider = fbProvider

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
    .withFacebookSignIn(facebookProvider)
    .withEmailSignIn()
  }

  var body: some View {
    NavigationStack {
      VStack {
        AuthPickerView()
        
        // Facebook Limited Login Control (Example)
        GroupBox {
          VStack(alignment: .leading, spacing: 8) {
            Text("Facebook Settings")
              .font(.headline)
            
            Toggle("Use Limited Login", isOn: $useLimitedLogin)
              .onChange(of: useLimitedLogin) { _, newValue in
                handleLimitedLoginToggle(newValue)
              }
            
            Text("Limited Login protects privacy by preventing Facebook tracking across apps.")
              .font(.caption)
              .foregroundColor(.secondary)
          }
        }
        .padding()
      }
      .environment(authService)
    }
  }
  
  private func handleLimitedLoginToggle(_ limitedLogin: Bool) {
    if limitedLogin {
      // User wants Limited Login - enable immediately
      facebookProvider.setLimitedLogin(true)
    } else {
      // User wants to disable Limited Login (enable tracking)
      // Request ATT permission first
      ATTrackingManager.requestTrackingAuthorization { status in
        Task { @MainActor in
          if status == .authorized {
            // User authorized tracking
            facebookProvider.setLimitedLogin(false)
          } else {
            // User denied tracking - force Limited Login back ON
            useLimitedLogin = true
            facebookProvider.setLimitedLogin(true)
          }
        }
      }
    }
  }
}
