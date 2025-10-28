//
//  ContentViewSheetExample.swift
//  FirebaseUI
//
//  Created by Ademola Fadumo on 20/10/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseAuthSwiftUI
import FirebaseGoogleSwiftUI
import FirebaseFacebookSwiftUI
import FirebasePhoneAuthSwiftUI

struct ContentViewSheetExample: View {
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
    .withTwitterSignIn()
    .withFacebookSignIn()
    .withEmailSignIn()
  }
  
  @State private var authService: AuthService
  @State private var isPresented: Bool = false
  
  var body: some View {
    FirebaseAuthView(
      authService: authService,
      isPresented: $isPresented
    ) {
      NavigationStack {
        VStack {
          if authService.authenticationState == .unauthenticated {
            Text("Not Authenticated")
          } else {
            Text("Authenticated - \(authService.currentUser?.email ?? "")")
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
        isPresented = authService.authenticationState == .unauthenticated
      }
      .onChange(of: authService.authenticationState) { oldValue, newValue in
        debugPrint("authService.authenticationState - \(newValue)")
        if newValue != .authenticating {
          isPresented = newValue == .unauthenticated
        }
      }
    }
  }
}

#Preview {
  ContentViewSheetExample()
}
