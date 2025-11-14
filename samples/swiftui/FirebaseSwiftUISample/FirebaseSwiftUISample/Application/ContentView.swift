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

import SwiftUI
import FirebaseAuth
import FirebaseAppleSwiftUI
import FirebasePhoneAuthSwiftUI
import FirebaseGoogleSwiftUI
import FirebaseTwitterSwiftUI
import FirebaseAuthSwiftUI
import FirebaseFacebookSwiftUI
import FirebaseOAuthSwiftUI


struct ContentView: View {
  init() {
//     Auth.auth().useEmulator(withHost: "127.0.0.1", port: 9099)

    let actionCodeSettings = ActionCodeSettings()

    actionCodeSettings.handleCodeInApp = true
    actionCodeSettings.url = URL(string: "https://flutterfire-e2e-tests.firebaseapp.com")
    actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
    actionCodeSettings.linkDomain = "flutterfire-e2e-tests.firebaseapp.com"
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
        scopes: ["openid", "profile", "email"],
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
    NavigationStack {
      VStack(spacing: 24) {
        NavigationLink {
          AuthPickerViewExample()
            .navigationTitle("Using AuthPickerView")
        } label: {
          VStack(alignment: .leading, spacing: 16) {
            Text("AuthPickerView example")
              .font(.headline)
              .fontWeight(.bold)
            Text("How to use with AuthPickerView")
            Text("• Pre-built authentication UI\n• Automatic flow management\n• Quick integration")
              .font(.caption)
              .foregroundColor(.secondary)
          }
          .multilineTextAlignment(.leading)
          .padding()
          .frame(maxWidth: .infinity, alignment: .leading)
          .background {
            RoundedRectangle(cornerRadius: 16)
              .fill(Color(UIColor.secondarySystemBackground))
              .frame(maxWidth: .infinity)
          }
        }
        .tint(Color(.label))
        NavigationLink {
          CustomViewExample()
            .navigationTitle("Using AuthService")
        } label: {
          VStack(alignment: .leading, spacing: 16) {
            Text("Custom View example")
              .font(.headline)
              .fontWeight(.bold)
            Text("How to use with AuthService with a custom view")
            Text("• Build custom authentication UI\n• Direct AuthService method calls\n• Full control over user experience")
              .font(.caption)
              .foregroundColor(.secondary)
          }
          .multilineTextAlignment(.leading)
          .padding()
          .frame(maxWidth: .infinity, alignment: .leading)
          .background {
            RoundedRectangle(cornerRadius: 16)
              .fill(Color(UIColor.secondarySystemBackground))
          }
        }
        .tint(Color(.label))
      }
      .padding()
      .navigationTitle("FirebaseUI Demo")
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    .environment(authService)
  }
}

#Preview {
  ContentView()
}
