//
//  FirebaseSwiftUIExampleApp.swift
//  FirebaseSwiftUIExample
//
//  Created by Russell Wheatley on 18/02/2025.
//

import FirebaseAuth
import FirebaseAuthSwiftUI
import FirebaseCore
import SwiftData
import SwiftUI

@main
struct FirebaseSwiftUIExampleApp: App {
  init() {
    FirebaseApp.configure()
  }

  var body: some Scene {
    WindowGroup {
      NavigationView {
        ContentView()
      }
    }
  }
}

struct ContentView: View {
  let authService: AuthService
  let emailAuthProvider: EmailPasswordAuthProvider

  init() {
    authService = AuthService()
    emailAuthProvider = EmailPasswordAuthProvider(authService: authService)
  }

  var body: some View {
    AuthPickerView {
      EmailPasswordButtonView(provider: emailAuthProvider)
    }.environment(authService)
  }
}
